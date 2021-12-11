FROM golang:1.17-alpine3.15 as builder
WORKDIR /app/
COPY . .
RUN go mod tidy
RUN go build -o simple main.go

FROM alpine:3.15.0
COPY --from=builder /app/simple /app/simple
RUN adduser -D simple
RUN chown -R simple:simple /app
USER simple
CMD ["/app/simple"]