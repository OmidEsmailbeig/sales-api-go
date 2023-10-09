package main

import (
	"log"
	"os"
	"os/signal"
	"syscall"
)

var build = "develop"

func main() {
	log.Println("Starting service", build)
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
