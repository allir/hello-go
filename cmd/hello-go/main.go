package main

import (
	"fmt"
	"log"
	"net/http"
	"net/http/httputil"
	"os"
)

func handler(w http.ResponseWriter, r *http.Request) {
	hostname, err := os.Hostname()
	if err != nil {
		log.Fatal(err)
	}

	title := os.Getenv("HELLO_VAR")
	if title == "" {
		title = "allir"
	}

	reqDump, err := httputil.DumpRequest(r, true)
	if err != nil {
		log.Fatal(err)
	}

	log.Println(r.URL.Path + " - writing response with title = " + title)
	fmt.Fprintf(w, "Hello from %s\n\n%s\n\n\nServing from %s\n", title, string(reqDump), hostname)
}

func handlerFavIcon(w http.ResponseWriter, r *http.Request) {}

func main() {
	log.Println("Starting server, listening on port 8080")

	http.HandleFunc("/favicon.ico", handlerFavIcon)
	http.HandleFunc("/", handler)
	log.Fatal(http.ListenAndServe(":8080", nil))
}
