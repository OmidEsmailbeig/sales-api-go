package main

import (
	"fmt"
	"log"
	"os"
	"os/signal"
	"runtime"
	"syscall"

	"go.uber.org/automaxprocs/maxprocs"
)

var build = "develop"

func main() {

	// Set the correct number of threads for the service
	// based on what is available either by the machine or quotas
	if _, err := maxprocs.Set(); err != nil {
		fmt.Printf("maxprocs: %v", err)
		os.Exit(1)
	}

	g := runtime.GOMAXPROCS(0)

	log.Printf("Starting service build[%s] CPU[%d]", build, g)
	defer log.Println("Service ended")

	shutdown := make(chan os.Signal, 1)
	signal.Notify(shutdown, syscall.SIGINT, syscall.SIGTERM)

	done := make(chan struct{})

	go func() {
		sig := <-shutdown
		log.Printf("Received signal: %v", sig)

		log.Println("Stopping service")

		close(done)
	}()

	<-done

}
