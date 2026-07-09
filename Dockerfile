FROM ruby:3.0

# Set the working directory
WORKDIR /app

# Install dependencies
COPY server/Gemfile server/Gemfile.lock ./
RUN bundle install

# Copy the server code
COPY server/ ./server

# Copy the client code
COPY client/ ./client

# Install Node.js and npm for the client
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
    apt-get install -y nodejs && \
    cd client && npm install

# Expose the port the app runs on
EXPOSE 4567

# Command to run the application
CMD ["ruby", "server/app.rb"]