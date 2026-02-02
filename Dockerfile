# Dockerfile for Grabby

# --- Builder Stage ---
# Use an official Rust image as a builder.
# We use -slim to keep the image size smaller.
FROM rust:nightly-slim as builder

# Set the working directory
WORKDIR /usr/src/grabby

# Install system dependencies required for the build (e.g., for openssl-sys)
RUN apt-get update && apt-get install -y pkg-config libssl-dev

# Copy Cargo configuration files
COPY Cargo.toml Cargo.lock ./

# Create a dummy source file and build dependencies to cache them
RUN mkdir src && \
    echo "fn main() {}" > src/main.rs && \
    cargo build --release

# Remove the dummy source and copy the actual source code
RUN rm -rf src
COPY src ./

# Build the final application
# This will use the cached dependencies from the previous step
RUN cargo build --release

# --- Runner Stage ---
# Use a minimal image for the final container
FROM debian:bookworm-slim

# Install runtime dependencies
# yt-dlp is the core media downloader for grabby
# ffmpeg is used for auto-resizing media
# ca-certificates is needed for making HTTPS requests
RUN apt-get update && apt-get install -y --no-install-recommends \
    yt-dlp \
    gallery-dl \
    ffmpeg \
    ca-certificates \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy the compiled binary from the builder stage
COPY --from=builder /usr/src/grabby/target/release/grabby /usr/local/bin/grabby

# Copy the configuration file if it exists in the repo
# This allows configuring the bot without env vars for server settings
COPY config.example.toml /config.toml

# Expose the port our web server will listen on.
# This is crucial for Koyeb's health checks.
EXPOSE 8000

# Set the command to run the application
# It will look for config at /config.toml if CONFIG_FILE is not set
CMD ["grabby", "--config", "/config.toml"]
