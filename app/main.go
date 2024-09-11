package main

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"os"
	"os/signal"
	"runtime/debug"
	"syscall"
	"time"

	"github.com/apex/log"
	"github.com/julienschmidt/httprouter"
	"github.com/richardwilkes/toolbox/atexit"
	"github.com/spf13/cobra"
)

type reponseWrapper struct {
	http.ResponseWriter
	statusCode int
	body       bytes.Buffer
}

func newResponseLogger(w http.ResponseWriter) *reponseWrapper {
	return &reponseWrapper{ResponseWriter: w, statusCode: http.StatusOK}
}

func (r *reponseWrapper) WriteHeader(statusCode int) {
	r.statusCode = statusCode
	r.ResponseWriter.WriteHeader(statusCode)
}

func (r *reponseWrapper) Write(body []byte) (int, error) {
	r.body.Write(body)
	return r.ResponseWriter.Write(body)
}

type response struct {
	Message   string `json:"message"`
	Timestamp int64  `json:"timestamp,omitempty"`
}

func main() {
	var rootCommand = &cobra.Command{
		Use:   "simpleApp",
		Short: "Simple App",
		RunE: func(cmd *cobra.Command, args []string) error {
			return run()
		},
	}

	if err := rootCommand.Execute(); err != nil {
		log.Fatalf("runtime error %s", err)
	}
	atexit.Exit(0)
}

func run() error {

	router := httprouter.New()
	router.PanicHandler = panicHandler

	router.GET("/healthcheck", logMiddleware(healthCheckHandler()))
	router.GET("/hello_world", logMiddleware(hellowWorldHandler()))
	router.GET("/current_time", logMiddleware(currentTimeHandler()))

	srv := &http.Server{
		Addr:    ":8080",
		Handler: router,
	}

	idleConnsClosed := make(chan struct{})
	go func() {
		sigint := make(chan os.Signal, 1)
		signal.Notify(sigint, syscall.SIGINT, syscall.SIGTERM)

		<-sigint

		ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
		defer cancel()

		if err := srv.Shutdown(ctx); err != nil {
			log.Infof("Server shutdown error: %v", err)
		}

		close(idleConnsClosed)
	}()

	// Start the server
	log.Infof("Starting server on :8080")
	if err := srv.ListenAndServe(); err != http.ErrServerClosed {
		log.Fatalf("ListenAndServe error: %v", err)
	}

	<-idleConnsClosed
	log.Infof("Server gracefully stopped.")

	return nil
}

// panicHandler handle any panic on routes
func panicHandler(w http.ResponseWriter, req *http.Request, rcv interface{}) {
	log.Errorf("A panic was captured on route %s ", req.URL.Path)
	log.Errorf("%+v", rcv)
	log.Error(string(debug.Stack()))

	w.WriteHeader(http.StatusInternalServerError)
}

func healthCheckHandler() httprouter.Handle {
	return func(w http.ResponseWriter, req *http.Request, params httprouter.Params) {
		w.WriteHeader(http.StatusOK)
	}
}

func hellowWorldHandler() httprouter.Handle {
	return func(w http.ResponseWriter, req *http.Request, params httprouter.Params) {
		successResponse(w, http.StatusOK, response{Message: "Hello World!"})
	}
}

func currentTimeHandler() httprouter.Handle {
	return func(w http.ResponseWriter, req *http.Request, params httprouter.Params) {
		resp := response{
			Message:   fmt.Sprintf("Hello %s", req.URL.Query().Get("name")),
			Timestamp: time.Now().Unix(),
		}
		successResponse(w, http.StatusOK, resp)
	}
}

func successResponse(w http.ResponseWriter, statusCode int, response interface{}) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(statusCode)
	json.NewEncoder(w).Encode(response)
}

func logMiddleware(next httprouter.Handle) httprouter.Handle {
	return func(w http.ResponseWriter, req *http.Request, params httprouter.Params) {
		log.Infof("[%s] %s %s %s", req.Method, req.RequestURI, req.RemoteAddr, req.UserAgent())

		rw := newResponseLogger(w)
		next(rw, req, params)

		log.Infof("Response status: %d, Body: %s", rw.statusCode, rw.body.String())
	}
}
