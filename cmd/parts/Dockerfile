FROM docker.io/library/golang:latest AS builder
ARG GITHUB_USER=podtato-head
LABEL org.opencontainers.image.source = "https://github.com/${GITHUB_USER}/podtato-head"

ARG PART
ENV PART=${PART}

ENV GO111MODULE=on \
    CGO_ENABLED=0

WORKDIR /build

COPY go.mod .
COPY go.sum .
RUN go mod download

COPY . .
RUN go build -o /serve-${PART} ./cmd/parts

EXPOSE 9000

FROM scratch
ARG GITHUB_USER=podtato-head
LABEL org.opencontainers.image.source = "https://github.com/${GITHUB_USER}/podtato-head"
ARG PART
ENV PART=${PART}
COPY --from=builder /serve-${PART} /serve
ENTRYPOINT ["/serve"]
