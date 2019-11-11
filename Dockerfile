FROM golang:1.13 as build
WORKDIR /go/src/hello-go
ADD main.go main.go
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags "-s -w" -a -installsuffix cgo -o hello


FROM scratch 
WORKDIR /hello
COPY --from=build /go/src/hello-go/hello .
EXPOSE 8080
ENV HELLO_VAR allir
CMD ["./hello"]
