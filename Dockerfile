# Use official Ubuntu base image
FROM ubuntu:20.04

LABEL maintainer="coubis"

ARG DEBIAN_FRONTEND=noninteractive

# Set working directory
WORKDIR /var/www/html

# Install Apache
RUN apt-get update && \
    apt-get install -y apache2 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create subdirectories for both applications
RUN mkdir -p app01 app02

# Copy both applications into Apache HTML directory
COPY application-01/ app01/
COPY application-02/ app02/

# Expose Apache default port
EXPOSE 80

# Start Apache in foreground
CMD ["apachectl", "-D", "FOREGROUND"]
