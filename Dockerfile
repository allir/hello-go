FROM golang:1 as build
WORKDIR /go/src/app
ADD cmd/hello-go/main.go main.go 
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o hello main.go


FROM scratch 
WORKDIR /hello-go
COPY --from=build /go/src/app/hello .
EXPOSE 8080
ENV HELLO_VAR allir
CMD ["./hello"]
