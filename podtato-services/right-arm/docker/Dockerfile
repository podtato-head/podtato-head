FROM golang:alpine AS builder

# Set necessary environment variables needed for our image
ENV GO111MODULE=on \
    CGO_ENABLED=0 \
    GOOS=linux \
    GOARCH=amd64

# Move to working directory /build
WORKDIR /build

# Copy and download dependency using go mod
# COPY go.mod .
# COPY go.sum .
# RUN go mod download

# Copy the code into the container
COPY . .

# Build the application
RUN go build -o podtatoserver .

# Move to /dist directory as the place for resulting binary folder
WORKDIR /dist

# Copy binary from build to main folder
RUN cp /build/podtatoserver .

# Build a small image
FROM scratch

COPY --from=builder /dist/podtatoserver /
COPY /static  /static

ARG VERSION
ENV VERSION=${VERSION}

# Export necessary port
EXPOSE 9000

# Command to run when starting the container
CMD ["/podtatoserver"]
