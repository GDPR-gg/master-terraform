package mock

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net/http"
	"os"
	"os/exec"
	"os/signal"
	"path/filepath"
	"strconv"
	"strings"
	"syscall"
	"time"

	"github.com/go-icap/icap"
	"github.com/hashicorp/go-hclog"
	"gopkg.in/src-d/go-billy.v4/osfs"

	gitpktline "gopkg.in/src-d/go-git.v4/plumbing/format/pktline"
	gitcapability "gopkg.in/src-d/go-git.v4/plumbing/protocol/packp/capability"
	gittransport "gopkg.in/src-d/go-git.v4/plumbing/transport"
	gitserver "gopkg.in/src-d/go-git.v4/plumbing/transport/server"
)

const (
	DesiredStatusCodeHeader = "X-Desired-Response-Code"
)

// Transformer is an interface that applies some mutation to a mock response.
// To properly implement the Transformer interface, it must be possible to
// "chain" transformations together. They should not make changes that would
// invalidate other transformations.
type Transformer interface {
	Transform(r io.Reader) (t io.Reader, err error)
}

// Option is a configuration option for passing to the MockServer constructor.
// This is used to implement the "Functional Options" pattern:
//    https://dave.cheney.net/2014/10/17/functional-options-for-friendly-apis
type Option func(*MockServer) error

// MockServer starts the HTTP and ICAP servers that are required to run the
// mocking system.
type MockServer struct {
	mockFilesRoot string

	icapPort int
	apiPort  int

	RouteConfig  RouteConfig
	transformers []Transformer

	logger hclog.Logger
}

// NewMockServer is a creator for a new MockServer. It makes use of functional
// options to provide additional configuration on top of the defaults.
func NewMockServer(options ...Option) (*MockServer, error) {
	ms := &MockServer{
		mockFilesRoot: "/mocks",

		icapPort: 11344,
		apiPort:  80,

		logger: hclog.NewNullLogger(),
	}

	for _, o := range options {
		if err := o(ms); err != nil {
			return nil, err
		}
	}

	_, err := os.Open(ms.mockFilesRoot)
	if err != nil {
		return nil, fmt.Errorf(
			"invalid mock file directory %v: %w", ms.mockFilesRoot, err,
		)
	}

	rc, err := ParseRoutes(filepath.Join(ms.mockFilesRoot, "routes.hcl"))
	if err != nil {
		return nil, fmt.Errorf(
			"invalid mock routes file %s: %w",
			filepath.Join(ms.mockFilesRoot, "routes.hcl"), err,
		)
	}
	ms.RouteConfig = rc

	return ms, nil
}

// WithMockRoot is a functional option that changes where MockServer looks for
// mock files.
func WithMockRoot(root string) Option {
	return func(m *MockServer) error {
		m.mockFilesRoot = root
		return nil
	}
}

// WithDefaultVariables is a functional option that sets some default
// transformers. These are used in testing, but can also be used to supply
// "global" values.
func WithDefaultVariables(vars ...*VariableSubstitution) Option {
	return func(m *MockServer) error {
		for _, v := range vars {
			m.addVariableSubstitution(v)
		}
		return nil
	}
}

// WithAPIPort is a functional option that changes the port the Mock server
// runs its API on.
func WithAPIPort(port int) Option {
	return func(m *MockServer) error {
		m.apiPort = port
		return nil
	}
}

// WithLogger is a functional option that configures the Mock server with a
// given go-hclog Logger.
func WithLogger(logger hclog.Logger) Option {
	return func(m *MockServer) error {
		if logger == nil {
			return fmt.Errorf("cannot call WithLogger with nil Logger, use NewNullLogger instead")
		}
		m.logger = logger
		return nil
	}
}

// Serve starts the actual servers and handlers, then waits for them to exit
// or for an Interrupt signal.
func (ms *MockServer) Serve() error {
	// ICAP makes use of these handlers on the DefaultServeMux
	http.HandleFunc("/", ms.mockHandler)
	icap.HandleFunc("/icap", ms.interception)

	// We also create a custom ServeMux mock-proxy for API endpoints
	apiMux := http.NewServeMux()
	apiMux.HandleFunc("/substitution-variables", ms.substitutionVariableHandler)

	icapErrC := make(chan error)
	apiErrC := make(chan error)

	// We also want to gracefully stop when the OS asks us to
	killSignal := make(chan os.Signal, 1)
	signal.Notify(killSignal, os.Interrupt, syscall.SIGINT, syscall.SIGTERM)

	go func() {
		ms.logger.Info("starting icap server on", "port", ms.icapPort)
		icapErrC <- icap.ListenAndServe(fmt.Sprintf(":%d", ms.icapPort), nil)
	}()
	go func() {
		ms.logger.Info("starting api server on", "port", ms.apiPort)
		apiErrC <- http.ListenAndServe(fmt.Sprintf(":%d", ms.apiPort), apiMux)
	}()

	for {
		select {
		case err := <-icapErrC:
			if err != nil {
				ms.logger.Error("exiting due to icap error", "error", err.Error())
			}
			return err
		case err := <-apiErrC:
			if err != nil {
				ms.logger.Error("exiting due to api error", "error", err.Error())
			}
			return err
		case sig := <-killSignal:
			ms.logger.Info("exiting due to os signal", "signal", sig)
			return nil
		}
	}
}

// interception runs the ICAP handler. When a request is input, we either:
//   1. If it matches a known "mocked" host, injects a response.
//   2. If it does not, returns a 204 which allows the request unmodifed.
func (ms *MockServer) interception(w icap.ResponseWriter, req *icap.Request) {
	switch req.Method {
	case "OPTIONS":
		h := w.Header()

		h.Set("Methods", "REQMOD")
		h.Set("Allow", "204")
		h.Set("Preview", "0")
		h.Set("Transfer-Preview", "*")
		w.WriteHeader(http.StatusOK, nil, false)
	case "REQMOD":
		ms.logger.Info("REQMOD request for", "host", req.Request.Host)
		ms.logger.Info("REQMOD request URL", "url", fmt.Sprintf("%+v", req.Request.URL))

		route, _ := ms.RouteConfig.MatchRoute(req.Request.URL)
		if route != nil {
			icap.ServeLocally(w, req)
		} else {
			// Return the request unmodified.
			w.WriteHeader(http.StatusNoContent, nil, false)
		}
	default:
		// This ICAP server is only able to handle REQMOD, will not be using
		// RESMOD mode.
		w.WriteHeader(http.StatusMethodNotAllowed, nil, false)
		ms.logger.Error("invalid request method to ICAP server", "method", req.Method)
	}
}

// mockHandler receives requests and based on them, returns one of the known
// .mock files, after running it through the configured Transformers.
func (ms *MockServer) mockHandler(w http.ResponseWriter, r *http.Request) {
	ms.logger.Info("MOCK request", "url", r.URL.String())

	successCode := http.StatusOK
	successCodeString := r.Header.Get(DesiredStatusCodeHeader)
	if successCodeString != "" {
		var err error
		successCode, err = strconv.Atoi(successCodeString)
		if err != nil {
			ms.logger.Error(fmt.Sprintf("failed to parse %s", DesiredStatusCodeHeader),
				"error", err.Error())
			http.Error(w, fmt.Sprintf("failed to parse %s: %s",
				DesiredStatusCodeHeader, err.Error()), http.StatusInternalServerError)
		}
	}

	route, err := ms.RouteConfig.MatchRoute(r.URL)
	if err != nil || route == nil {
		if err == nil {
			err = fmt.Errorf("found no matching route for %s", r.URL.String())
		}
		ms.logger.Error("failed to find a matching route", "error", err.Error())
		http.Error(w, fmt.Sprintf("failed to find a matching route: %s",
			err.Error()), http.StatusInternalServerError)
		return
	}

	ms.logger.Info("parsing URL", "route", fmt.Sprintf("%+v", route), "url", r.URL)
	path, localTransformers, err := route.ParseURL(r.URL)
	if err != nil {
		ms.logger.Error("failed to parse mock URL for route", "error", err.Error())
		http.Error(w, fmt.Sprintf("failed to parse mock URL for route: %s",
			err.Error()), http.StatusInternalServerError)
	}
	ms.logger.Info("parsed URL produced path", "path", path)

	switch route.Type {
	case "http":
		ms.logger.Info("detected an http mock attempt")
		fileName := filepath.Join(ms.mockFilesRoot, path)
		mock, err := os.Open(fileName)
		if err != nil {
			ms.logger.Error("failed opening mock file", "error", err.Error())
			http.Error(w, fmt.Sprintf("failed opening mock file: %s", err.Error()), http.StatusNotFound)
			return
		}

		// Apply the configured transformations to the mock file
		transformers := append(ms.transformers, localTransformers...)
		var res io.Reader = mock
		for _, t := range transformers {
			res, err = t.Transform(res)
			if err != nil {
				ms.logger.Error("error applying transformations", "error", err.Error())
				http.Error(
					w,
					fmt.Sprintf("error applying transformations: %s", err.Error()),
					http.StatusInternalServerError,
				)
				return
			}
		}

		w.WriteHeader(successCode)
		_, err = io.Copy(w, res)
		if err != nil {
			ms.logger.Error("failed copying to response", "error", err.Error())
			http.Error(
				w,
				"failed copying to response",
				http.StatusInternalServerError,
			)
			return
		}
	case "git":
		ms.logger.Info("detected a git clone attempt")

		mockFS := osfs.New(filepath.Join(ms.mockFilesRoot))
		loader := gitserver.NewFilesystemLoader(
			mockFS,
		)
		gitServer := gitserver.NewServer(loader)

		ep, err := gittransport.NewEndpoint(path)
		if err != nil {
			ms.logger.Error("failed creating transport", "error", err.Error())
			http.Error(w, fmt.Sprintf("failed creating transport: %s",
				err.Error()), http.StatusInternalServerError)
			return
		}

		fs, _ := mockFS.Chroot(ep.Path)
		ms.logger.Info("attempting to load local git repo", "filepath", fmt.Sprintf("%+v", fs.Root()))

		sess, err := gitServer.NewUploadPackSession(ep, nil)
		if err != nil {
			ms.logger.Error("failed creating git-upload-pack session", "error", err.Error())
			http.Error(w, fmt.Sprintf("failed creating git-upload-pack session: %s",
				err.Error()), http.StatusInternalServerError)
			return
		}
		defer sess.Close()

		if strings.HasSuffix(r.URL.String(), "info/refs?service=git-upload-pack") {
			ms.logger.Info("detected a reference advertisement request")

			refs, err := sess.AdvertisedReferences()
			if err != nil {
				ms.logger.Error("failed to load reference advertisement", "error", err.Error())
				http.Error(w, fmt.Sprintf("failed to load reference advertisement: %s",
					err.Error()), http.StatusInternalServerError)
				return
			}

			// Add the Shallow capability
			if err := refs.Capabilities.Add(gitcapability.Shallow); err != nil {
				ms.logger.Error("failed to add shallow capability", "error", err.Error())
				http.Error(w, fmt.Sprintf("failed to add shallow capability: %s",
					err.Error()), http.StatusInternalServerError)
				return
			}

			// To successfully interact with smart git clone, we must set a
			// prefix saying which service this is.
			refs.Prefix = [][]byte{
				[]byte(
					fmt.Sprintf("# service=%s", gittransport.UploadPackServiceName),
				),
				// Note: This is a semantically significant flush, and I don't
				// really know why, but do not touch.
				gitpktline.Flush,
			}
			w.Header().Add("Content-Type", "application/x-git-upload-pack-advertisement")
			w.Header().Add("Cache-Control", "no-cache")

			w.WriteHeader(successCode)
			if err := refs.Encode(w); err != nil {
				ms.logger.Error("failed writing response", "error", err.Error())
				http.Error(w, fmt.Sprintf("failed writing response: %s",
					err.Error()), http.StatusInternalServerError)
				return
			}
			return
		} else if strings.HasSuffix(r.URL.String(), "git-upload-pack") {
			ms.logger.Info("detected a git-upload-pack request")

			ctx, cancelFunc := context.WithTimeout(context.Background(), 30*time.Second)
			defer cancelFunc()

			w.Header().Add("Content-Type", "application/x-git-upload-pack-result")
			w.Header().Add("Cache-Control", "no-cache")

			// Originally tried implementing `upload-pack` in `go-git`, but
			// this got complicated, and git --stateless-rpc serves this purpose
			// well.
			cmd := exec.CommandContext(ctx, "git", "upload-pack", "--stateless-rpc", fs.Root())

			// Set the stdin to read from the request, and the stdout to write
			// to the response.
			cmd.Stdin = r.Body
			cmd.Stdout = w

			if err := cmd.Start(); err != nil {
				ms.logger.Error("error starting git upload-pack", "error", err.Error())
				http.Error(w, fmt.Sprintf("error starting git upload-pack: %s",
					err.Error()), 500)
				return
			}

			if err := cmd.Wait(); err != nil {
				if err != nil {
					// For shallow clones, the exit code will be 128, if this is
					// the case, don't error.
					var exerr *exec.ExitError
					if errors.As(err, &exerr) {
						if exerr.ExitCode() != 128 {
							ms.logger.Error("error running git upload-pack", "error", err.Error())
							http.Error(w, fmt.Sprintf("error running git upload-pack: %s",
								err.Error()), 500)
							return
						}
					} else {
						ms.logger.Error("error running git upload-pack", "error", err.Error())
						http.Error(w, fmt.Sprintf("error running git upload-pack: %s",
							err.Error()), 500)
						return
					}
				}
			}

			return
		} else {
			ms.logger.Error("detected an unknown git request type", "url", r.URL.String())
			http.Error(w, fmt.Sprintf("detected an unknown git request type: %s",
				r.URL.String()), http.StatusNotFound)
			return
		}
	default:
		ms.logger.Error("detected an unknown route type", "url", r.URL.String())
		http.Error(w, fmt.Sprintf("detected an unknown route type: %s",
			r.URL.String()), http.StatusNotFound)
		return
	}
}

// substitutionVariableHandler can receive a GET or POST request.
//   GET) Returns a JSON representation of the current variable substitutions.
//   POST) Adds a new variable substitution based on multi-part form values.
//         curl -X POST -F "key=A" -F "value=B" squid.proxy/substitution-variables
func (ms *MockServer) substitutionVariableHandler(
	w http.ResponseWriter,
	r *http.Request,
) {
	switch r.Method {
	case http.MethodGet:
		resp := []struct {
			Key   string `json:"key"`
			Value string `json:"value"`
		}{}

		for _, transform := range ms.transformers {
			switch tr := transform.(type) {
			case *VariableSubstitution:
				resp = append(resp, struct {
					Key   string `json:"key"`
					Value string `json:"value"`
				}{
					Key:   tr.key,
					Value: tr.value,
				})
			}
		}

		js, err := json.Marshal(resp)
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}

		w.Header().Set("Content-Type", "application/json")
		_, _ = w.Write(js)
	case http.MethodPost:
		err := r.ParseMultipartForm(4096)
		if err != nil {
			http.Error(
				w,
				fmt.Sprintf("error parsing input form: %s", err.Error()),
				http.StatusInternalServerError,
			)
			return
		}

		key := r.PostForm.Get("key")
		value := r.PostForm.Get("value")

		if key == "" || value == "" {
			http.Error(
				w,
				"both key and value must be supplied",
				http.StatusBadRequest,
			)
			return
		}

		vs, err := NewVariableSubstitution(key, value)
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}

		ms.addVariableSubstitution(vs)
		w.WriteHeader(http.StatusOK)
	}
}

// addVariableSubstitution adds a new variable substitution. It iterates the
// currently configured Transformers, and if an existing substitution for a
// variable with the new key already exists, replaces it instead of having two.
func (ms *MockServer) addVariableSubstitution(
	new *VariableSubstitution,
) {
	var replaced bool
	for idx, transform := range ms.transformers {
		switch tr := transform.(type) {
		case *VariableSubstitution:
			if tr.key == new.key {
				ms.transformers[idx] = new
				replaced = true
			}
		}
	}
	if !replaced {
		ms.transformers = append(ms.transformers, new)
	}
}
