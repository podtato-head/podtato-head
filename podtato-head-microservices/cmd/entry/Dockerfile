FROM docker.io/library/golang:latest AS builder
ARG GITHUB_USER=podtato-head
LABEL org.opencontainers.image.source = "https://github.com/${GITHUB_USER}/podtato-head"

ENV GO111MODULE=on \
    CGO_ENABLED=0

WORKDIR /build

COPY go.mod .
COPY go.sum .
RUN go mod download

COPY . .
RUN go build -o entry ./cmd/entry


FROM scratch
ARG GITHUB_USER=podtato-head
LABEL org.opencontainers.image.source = "https://github.com/${GITHUB_USER}/podtato-head"

COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /build/entry /entry

EXPOSE 9000

ENTRYPOINT ["/entry"]
