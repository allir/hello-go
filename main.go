package main

import(
	"os"
	"log"
	"fmt"
	"net/http"
)

func handler(w http.ResponseWriter, r *http.Request) {
	
	hostname, err := os.Hostname()
	if err != nil {
    panic(err)
	}
	
	title := os.Getenv("HELLO_VAR")
  if title == "" {
    title = "allir"
  }
	
  log.Println("Writing response with title = " + title)
	fmt.Fprintf(w, "Hello from " + title + "\nYou've requested %s\n\n\n\n\nServing from " + hostname, r.URL.Path) 

}

func main() {
  log.Println("Starting server, listening on port 8080")
	
  http.HandleFunc("/", handler)
	log.Fatal( http.ListenAndServe(":8080", nil) )
}

