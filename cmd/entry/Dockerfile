FROM docker.io/library/golang:latest AS builder
LABEL org.opencontainers.image.source = "https://github.com/joshgav/podtato-head"

ENV GO111MODULE=on \
    CGO_ENABLED=0

WORKDIR /build

COPY go.mod .
COPY go.sum .
RUN go mod download

COPY . .
RUN go build -o entry ./cmd/entry


FROM scratch
LABEL org.opencontainers.image.source = "https://github.com/joshgav/podtato-head"

COPY --from=builder /build/entry /entry

EXPOSE 9000

ENTRYPOINT ["/entry"]
