package main

import (
	"bytes"
	"encoding/json"
	"errors"
	"flag"
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"os/signal"
	"path/filepath"
	"regexp"
	"strconv"
	"strings"
	"syscall"
	"time"

	"github.com/mitchellh/mapstructure"
)

// WatchRE is used to parse a backend configuration. The config should
// look like "backend=tag.service@datacenter:port". However, the tag, port and
// datacenter are optional, so it can also be provided as "backend=service"
var WatchRE = regexp.MustCompile("^([^=]+)=([^.]+\\.)?([^.:@]+)(@[^.:]+)?(:[0-9]+)?$")

// WatchPath represents a path we need to watch
type WatchPath struct {
	Spec       string
	Backend    string
	Service    string
	Tag        string
	Datacenter string
	Port       int
}

// Config is used to configure the HAProxy connector
type Config struct {
	// DryRun is used to avoid actually modifying the file
	// or reloading HAProxy.
	DryRun bool `mapstructure:"dry_run"`

	// Address is the Consul HTTP API address
	Address string `mapstructure:"address"`

	// Path to the HAProxy template file
	Templates []string `mapstructure:"templates"`

	// Path to the HAProxy configuration file to write
	Paths []string `mapstructure:"paths"`

	// Command used to reload HAProxy
	ReloadCommand string `mapstructure:"reload_command"`

	// Backends are used to specify what we watch. Given as:
	// "name=(tag.)service"
	Backends []string `mapstructure:"backends"`

	// Quiet is how long we wait for a "quiet" period before
	// trigger the re-build and re-load. This allows us to
	// wait for the system to reach a quiescent state instead
	// of trigger constant updates.
	Quiet time.Duration `mapstructure:"quiet"`

	// MaxWait works with Quiet to limit the maximum amount of
	// time we wait before forcing a reload to take place.
	// In the case of an unstable system (constant flapping),
	// this allows progress to be made. Defaults to 4x the
	// Quiet value if not provided.
	MaxWait time.Duration `mapstructure:"max_wait"`

	// watches are the watches we need to track
	watches []*WatchPath
}

func main() {
	os.Exit(realMain())
}

// getConfig is used to read our configuration
func getConfig() (*Config, error) {
	var configFile string
	var backends []string
	var templates  []string
	var paths []string

	conf := &Config{}
	cmdFlags := flag.NewFlagSet("consul-haproxy", flag.ContinueOnError)
	cmdFlags.Usage = usage
	cmdFlags.StringVar(&conf.Address, "addr", "127.0.0.1:8500", "consul HTTP API address with port")
	cmdFlags.Var((*AppendSliceValue)(&templates), "in", "template path")
	cmdFlags.Var((*AppendSliceValue)(&paths), "out", "config path")
	cmdFlags.StringVar(&conf.ReloadCommand, "reload", "", "reload command")
	cmdFlags.StringVar(&configFile, "f", "", "config file")
	cmdFlags.BoolVar(&conf.DryRun, "dry", false, "dry run")
	cmdFlags.DurationVar(&conf.Quiet, "quiet", 0, "quiet period")
	cmdFlags.DurationVar(&conf.MaxWait, "max-wait", 0, "maximum wait for a quiet period")
	cmdFlags.Var((*AppendSliceValue)(&backends), "backend", "backend to populate")
	if err := cmdFlags.Parse(os.Args[1:]); err != nil {
		return nil, err
	}

	// Parse the configuration file if given
	if configFile != "" {
		if err := readConfig(configFile, conf); err != nil {
			return nil, fmt.Errorf("Failed to read config file: %v", err)
		}
	}

	// Merge the templates, paths, and backends together
	conf.Templates = append(conf.Templates, templates...)
	conf.Paths = append(conf.Paths, paths...)
	conf.Backends = append(conf.Backends, backends...)
	return conf, nil
}

// realMain is the actual entry point, but we wrap it to set
// a proper exit code on return
func realMain() int {
	if len(os.Args) == 1 {
		usage()
		return 1
	}

	// Read the configuration
	conf, err := getConfig()
	if err != nil {
		log.Printf("[ERR] %v", err)
		return 1
	}

	// Sanity check the configuration
	if errs := validateConfig(conf); len(errs) != 0 {
		for _, err := range errs {
			log.Printf("[ERR] %v", err)
		}
		return 1
	}

	// Start watching for changes
	stopCh, finishCh := watch(conf)

	// Wait for termination
	return waitForTerm(conf, stopCh, finishCh)
}

// readConfig is used to read a configuration file
func readConfig(path string, config *Config) error {
	// Read the file
	contents, err := ioutil.ReadFile(path)
	if err != nil {
		return err
	}

	// Decode the file
	var raw interface{}
	if err := json.NewDecoder(bytes.NewReader(contents)).Decode(&raw); err != nil {
		return err
	}

	// Map to our output
	if err := mapstructure.Decode(raw, config); err != nil {
		return err
	}
	return nil
}

// validateConfig is used to sanity check the configuration
func validateConfig(conf *Config) (errs []error) {
	// Check the template
	if len(conf.Templates) == 0 {
		errs = append(errs, errors.New("missing template path"))
	} else {
		for _, t := range conf.Templates {
			_, err := ioutil.ReadFile(t)
			if err != nil {
				errs = append(errs, fmt.Errorf("failed to read template '%s': %v", t, err))
			}
		}
	}

	if len(conf.Paths) == 0 && !conf.DryRun {
		errs = append(errs, errors.New("missing configuration path"))
	}

	if (len(conf.Templates) != len(conf.Paths)) && !conf.DryRun {
		errs = append(errs, errors.New("number of templates and paths do not match"))
	}

	if conf.ReloadCommand == "" && !conf.DryRun {
		errs = append(errs, errors.New("missing reload command"))
	}

	if len(conf.Backends) == 0 {
		errs = append(errs, errors.New("missing backends to populate"))
	}

	for _, b := range conf.Backends {
		parts := WatchRE.FindStringSubmatch(b)
		if parts == nil || len(parts) != 6 {
			errs = append(errs, fmt.Errorf("Backend '%s' could not be parsed", b))
			continue
		}
		var port int
		if parts[5] != "" {
			p, err := strconv.ParseInt(strings.TrimPrefix(parts[5], ":"), 10, 64)
			if err != nil {
				errs = append(errs, fmt.Errorf("Backend '%s' port could not be parsed", b))
				continue
			}
			port = int(p)
		}
		wp := &WatchPath{
			Spec:       parts[0],
			Backend:    parts[1],
			Tag:        strings.TrimSuffix(parts[2], "."),
			Service:    parts[3],
			Datacenter: strings.TrimPrefix(parts[4], "@"),
			Port:       port,
		}
		conf.watches = append(conf.watches, wp)
	}

	// Ensure a non-negative time interval
	if conf.Quiet < 0 || conf.MaxWait < 0 {
		errs = append(errs, errors.New("Cannot specify a negative time interval"))
	}

	// Handle setting a default MaxWait if a quiet period
	// is configured
	if conf.Quiet != 0 && conf.MaxWait == 0 {
		conf.MaxWait = 4 * conf.Quiet
	}

	return
}

// waitForTerm waits until we receive a signal to exit
func waitForTerm(conf *Config, stopCh, finishCh chan struct{}) int {
	signalCh := make(chan os.Signal, 1)
	signal.Notify(signalCh, os.Interrupt, syscall.SIGHUP)
	for {
		select {
		case sig := <-signalCh:
			switch sig {
			case syscall.SIGHUP:
				// Read the configuration
				log.Printf("[INFO] SIGHUP received, reloading configuration...")
				newConf, err := getConfig()
				if err != nil {
					log.Printf("[ERR] Failed to read new config: %v", err)
					continue
				}

				// Sanity check the configuration
				if errs := validateConfig(newConf); len(errs) != 0 {
					for _, err := range errs {
						log.Printf("[ERR] %v", err)
					}
					continue
				}

				// Switch to the new configuration
				conf = newConf

				// Stop the existing watcher
				close(stopCh)

				// Start a new watcher
				stopCh, finishCh = watch(conf)
				log.Printf("[INFO] Configuration reload complete")

			default:
				log.Printf("[WARN] Received %v signal, shutting down", sig)
				return 0
			}
		case <-finishCh:
			if conf.DryRun {
				return 0
			}
			log.Printf("[WARN] Aborting watching for changes, shutting down")
			return 1
		}
	}
	return 0
}

func usage() {
	cmd := filepath.Base(os.Args[0])
	fmt.Fprintf(os.Stderr, strings.TrimSpace(helpText)+"\n\n", cmd)
}

const helpText = `
Usage: %s [options]

  Watches a service group in Consul and dynamically configures
  an HAProxy backend. The process runs continuously, monitoring
  all the backends for changes. When there is a change, the template
  file is rendered to a destination path, and a reload command is
  invoked. This allows HAProxy configuration to be updated in real
  time using Consul.

  Backends are specified using the following syntax:

    app=release.webapp@east-aws:8000

  In this syntax, we are defining a template variable 'app',
  which is populated from the 'webapp' service, 'release' tag, in the
  'east-aws' datacenter, using port 8000. If the port is given it
  overrides any specified by the service. The tag, datacenter
  and port are optional. So we could also specify this as:

    app=webapp

  This exports the 'app' variable as just the nodes in the 'webapp'
  service in the local datacenter. Multiple backends can be specified,
  and even multiple watches for a given backend.

  For example:

    app=webapp@east-aws
    app=webapp@west-aws

  This will watch both the 'east-aws' and 'west-aws' datacenters to
  populate the nodes in the 'app' backend. This can be used to merge
  multiple tags, datacenters, etc into a single backend.

Options:

  -addr=127.0.0.1:8500  Provides the HTTP address of a Consul agent.
  -backend=spec         Backend specification. Can be provided multiple times.
  -dry                  Dry run. Emit config file to stdout.
  -f=path               Path to config file, overwrites CLI flags
  -in=path              Path to a template file.  Can be provided multiple times.
  -out=path             Path to output configuration file. Can be provided multiple times.
  -reload=cmd           Command to invoke to reload configuration
  -quiet=0s             Period to wait without updates before trigger reload.
  -max-wait=0s          Maxium time to wait for quiet period. Default 4x of -quiet.
`
