# syntax=docker/dockerfile:1

FROM golang:1.23-alpine AS builder
WORKDIR /build

COPY go.mod ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -trimpath -ldflags="-s -w" -o hello-go .

FROM alpine:3.20
RUN adduser -D -H -s /sbin/nologin appuser
USER appuser
WORKDIR /app

COPY --from=builder /build/hello-go ./hello-go

ENTRYPOINT ["./hello-go"]
