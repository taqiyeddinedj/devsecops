FROM golang:1.20-alpine3.16 as builder

# Install necessary packages
RUN apk --no-cache add git

# Set the working directory
WORKDIR /app

# Copy the source code and initialize the Go module
COPY . .

# Download dependencies
RUN go mod tidy

# Build the application
RUN go build -o myapp

# Use a scratch image for the final stage
FROM scratch

# Copy the binary from the builder stage
COPY --from=builder /app/myapp /myapp

# Exposing the port
EXPOSE 5000

# Run the application
CMD ["/myapp"]