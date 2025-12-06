FROM ruby:3.2.2

# Install dependencies
RUN apt-get update -qq && apt-get install -y \
  build-essential \
  libpq-dev \
  nodejs \
  npm \
  sqlite3 \
  libsqlite3-dev \
  git \
  vim \
  curl \
  && rm -rf /var/lib/apt/lists/*

# Install Yarn
RUN npm install -g yarn

# Install Rails
RUN gem install rails -v '~> 7.1.0'

# Set working directory
WORKDIR /workspace

# Configure git (for container use)
RUN git config --global --add safe.directory /workspace

# Install bundler
RUN gem install bundler

# Expose port 3000 for Rails server
EXPOSE 3000

# Keep container running
CMD ["/bin/bash"]
