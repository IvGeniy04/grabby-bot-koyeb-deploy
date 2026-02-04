# Dockerfile for Grabby

# --- Builder Stage ---
# Use an official Rust image as a builder.
# We use -slim to keep the image size smaller.
FROM rust:1.79-slim as builder

# Install nightly toolchain
RUN rustup update nightly && rustup toolchain install nightly && rustup default nightly

# Set the working directory
WORKDIR /usr/src/grabby

# Install system dependencies required for the build (e.g., for openssl-sys)
RUN apt-get update && apt-get install -y pkg-config libssl-dev

# Copy Cargo configuration files
COPY . .

# Build the final application
RUN cargo build --release

# --- Runner Stage ---
# Use a minimal image for the final container
FROM debian:bookworm-slim

# Install runtime dependencies
# yt-dlp is the core media downloader for grabby
# ffmpeg is used for auto-resizing media
# ca-certificates is needed for making HTTPS requests
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3-pip \
    python3-venv \
    ffmpeg \
    ca-certificates \
    && apt-get clean && rm -rf /var/lib/apt/lists/*
RUN python3 -m venv /opt/venv && \
    /opt/venv/bin/pip install -U yt-dlp gallery-dl
# Додано для пошуку утиліт з venv
ENV PATH="/opt/venv/bin:$PATH"

# Copy the compiled binary from the builder stage
COPY --from=builder /usr/src/grabby/target/release/grabby /usr/local/bin/grabby

# Copy the configuration file if it exists in the repo
# This allows configuring the bot without env vars for server settings
COPY config.example.toml /config.toml
COPY cookies.txt /config/cookies.txt

# Expose the port our web server will listen on.
# This is crucial for Koyeb's health checks.
EXPOSE 8000

ENV SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt

# Set the command to run the application
# It will look for config at /config.toml if CONFIG_FILE is not set
CMD ["grabby", "--config", "/config.toml"]
