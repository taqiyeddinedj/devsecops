# Use a more recent version of Go
FROM golang:1.20-alpine3.16 as builder

# Install necessary packages
RUN apk --no-cache add git

# Set the working directory
WORKDIR /app

# Copy the source code and initialize the Go module
COPY . .
RUN go mod init your-module-path

# Download dependencies
RUN go mod tidy

# Build the application
RUN go build -o myapp

# Use a scratch image for the final stage
FROM scratch

# Copy the binary from the builder stage
COPY --from=builder /app/myapp /myapp

# Optionally, copy any other necessary files
# COPY --from=builder /app/your-config.yaml /your-config.yaml

# Expose the port your application listens on
EXPOSE 5000

# Run the application
CMD ["/myapp"]