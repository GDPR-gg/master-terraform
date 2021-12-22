# DEPRECATED: consul-haproxy

**Deprecated!** This project is deprecated. Consul HAProxy has been replaced by [Consul Template](https://github.com/hashicorp/consul-template). This repository is kept for history and legacy purposes. Please use Consul Template instead.

---

This project provides `consul-haproxy`, a daemon for dynamically
configuring HAProxy using data from Consul.

The daemon watches any number of backends for updates, and when
appropriate renders an configuration template for HAProxy and then
invokes a reload command, which can gracefully reload HAProxy. This
allows for a zero-downtime reload of HAProxy which is populated by
Consul.

## Download & Compilation

Download a release from the [releases page](https://github.com/hashicorp/consul-haproxy/releases), or compile from source:

```
$ make
$ ./bin/consul-haproxy -h
```

## Usage

The `consul-haproxy` command takes a number of CLI flags:

* `-addr` - Provides the HTTP address of a Consul agent. By default this
  assumes a local agent at "127.0.0.1:8500".

* `-backend` - Backend specification. Can be provided multiple times.
  The specification of a backend is documented below.

* `-dry` - Dry run. Emit config file to stdout.

* `-f` - Path to config file, overwrites CLI flags. The format of the
  file is documented below.

* `-in`- Path to a template file. This is the template that is rendered
  to generate the configuration file at `-out`. It uses the Golang templating
  system. Docs for that are [here](http://golang.org/pkg/text/template/).
  Can be provided multiple times. If specified multiple times, specify the
  same number of paths with `-out`.

* `-out` - Path to output configuration file. This path must be writable
  by `consul-haproxy` or the file cannot be updated. This can be specified
  multiple times.

* `-reload` - Command to invoke to reload configuration. This command can
  be any executable, and should be used to reload HAProxy. This is invoked
  only after the configuration file is updated.

* `-quiet` - Quiet specifies a duration of time to wait for no updates
  before writing out the new configuration. This allows for waiting until
  a service stabilizes to prevent many different reloads.

* `-max-wait` - Max wait is used to limit how waiting is done for a quiet
  period before forcing a reload. This defaults to 4x the `-quiet` value.
  As an example, if `-quiet=30s` but the backends are constantly flapping,
  a refresh will be forced after 2 minutes.

In addition to using CLI flags, `consul-haproxy` can be configured using a
file given the `-f` flag. A configuration file overrides any values given by
the CLI unless otherwise specified. The configuration file should be a JSON
object with the following keys:

* `address` - Same as `-addr` CLI flag.
* `backends` - A list of backend specifications. This is merged with any
  backends provided via the CLI.
* `dry_run` - Same as `-dry` CLI flag.
* `paths` - Same as `-out` CLI flag. . This value should be a list of paths and
  is merged with any paths provided via the CLI.
* `reload_command` - Same as `-reload` CLI flag.
* `templates` - Same as `-in` CLI flag. This value should be a list of templates
  and is merged with any paths provided via the CLI.
* `quiet` - Same as `-quiet` CLI flag.
* `max_wait` - Same as `-max-wait` CLI flag.

## Backend Specification

One of the key configuration values to `consul-haproxy` is the backends that
it should monitor. These are the service entries that are watched for changes
and used to populate the configuration file. The syntax for a backend is:

    backend_name=tag.service@datacenter:port

The specification provides a variable name for the template `backend_name`,
which is defined as the entries that match the given tag and service for a specific
datacenter. A port can also be provided, which overrides the port specified by
the service. The tag, datacenter, and port are all optional and can be omitted.

Below are a few examples:

* `app=release.webapp` - This defines a template variable `app` which watches for
  the `webapp` service, filtering on the `release` tag.

* `db=mysql@east-aws:5500` - This defines a template variable `db` which watches for
  the `mysql` service in the `east-aws` datacenter, using port 5500.

A useful features is the ability to specify multiple backends with the same variable
name. This causes the nodes to be merged. This can be used to merge nodes with various
tags, or different datacenters together. As an example, we can define:

    app=webapp@dc1
    app=webapp@dc2
    app=webapp@dc3

This backend specification sets `app` variable to be the union of the servers
in the `dc1`, `dc2`, and `dc3` datacenters.

## Template Language

The template language is the Golang text/template package, which is
[fully documented here](http://golang.org/pkg/text/template/). However, the
basic usage is quite simple.

As an example, suppose we define a simple backends with:

    app=webapp@east-aws:8000
    cache=redis


We might provide a very basic template like:

    global
        daemon
        maxconn 256

    defaults
        mode tcp
        timeout connect 5000ms
        timeout client 60000ms
        timeout server 60000ms

    listen http-in
        bind *:80{{range .app}}
        {{.}} maxconn 32{{end}}

    listen cache-in
        bind *:4444{{range .cache}}
        {{.}} maxconn 64{{end}}

This will populate the `http-in` block with the servers
in the `app` backend, and the `cache-in` with the servers
in the `cache` backend. This template will be re-rendered when
any of those servers changing, allowing for dynamic updates.

## Example

We run the example below against our
[NYC demo server](http://nyc3.demo.consul.io). This lets you set
quickly test consul-haproxy.

First lets create a simple template:

    global
        daemon
        maxconn 256

    defaults
        mode tcp
        timeout connect 5000ms
        timeout client 60000ms
        timeout server 60000ms

    listen http-in
        bind *:8000{{range .c}}
        {{.}}{{end}}

Now, we can run the following to get our output configuration:

    consul-haproxy -addr=demo.consul.io -in in.conf -backend "c=consul@nyc3:80" -backend "c=consul@sfo1:80" -dry

When this runs, we should see something like the following:

    global
        daemon
        maxconn 256

    defaults
        mode tcp
        timeout connect 5000ms
        timeout client 60000ms
        timeout server 60000ms

    listen http-in
        bind *:8000
        server 0_nyc3-consul-1_consul 192.241.159.115:80
        server 0_nyc3-consul-2_consul 192.241.158.205:80
        server 0_nyc3-consul-3_consul 198.199.77.133:80
        server 1_sfo1-consul-2_consul 162.243.155.82:80
        server 1_sfo1-consul-1_consul 107.170.195.169:80
        server 1_sfo1-consul-3_consul 107.170.195.158:80

## Varnish Example


derived from the varnish director example from the varnish page: https://www.varnish-cache.org/docs/trunk/users-guide/vcl-backends.html#directors

	import directors;    # load the directors
	{{range .c}}
	backend {{.Node}}_{{.ID}} { 
	    .host = "{{.IP}}";
	    .port = "{{.Port}}";
	}{{end}}

	sub vcl_init {
	    new bar = directors.round_robin();
	{{range .c}}
	    bar.add_backend({{.Node}}_{{.ID}});{{end}}
	}

	sub vcl_recv {
	    # send all traffic to the bar director:
	    set req.backend_hint = bar.backend();
	}

Now, we run the following command:

    consul-haproxy -addr=demo.consul.io -in in.conf -backend "c=consul@nyc1:80" -backend "c=consul@sfo1:80" -dry

The following should return:

	backend 0_nyc1-server-1_consul {
	    .host = "192.241.159.115";
	    .port = "80";
	}
	backend 0_nyc1-server-3_consul {
	    .host = "198.199.77.133";
	    .port = "80";
	}
	backend 0_nyc1-server-2_consul {
	    .host = "162.243.162.228";
	    .port = "80";
	}
	backend 1_sfo1-server-3_consul {
	    .host = "107.170.196.151";
	    .port = "80";
	}
	backend 1_sfo1-server-2_consul {
	    .host = "107.170.195.154";
	    .port = "80";
	}
	backend 1_sfo1-server-1_consul {
	    .host = "162.243.153.242";
	    .port = "80";
	}

	sub vcl_init {
	    new bar = directors.round_robin();

	    bar.add_backend(0_nyc1-server-1_consul);
	    bar.add_backend(0_nyc1-server-3_consul);
	    bar.add_backend(0_nyc1-server-2_consul);
	    bar.add_backend(1_sfo1-server-3_consul);
	    bar.add_backend(1_sfo1-server-2_consul);
	    bar.add_backend(1_sfo1-server-1_consul);
	}

	sub vcl_recv {
	    # send all traffic to the bar director:
	    set req.backend_hint = bar.backend();
	}



