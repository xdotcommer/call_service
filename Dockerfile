# Use a lightweight Ruby image
FROM ruby:3.3

# Set the working directory inside the container
WORKDIR /app

# Install required OS-level dependencies
RUN apt-get update -qq && apt-get install -y build-essential libsqlite3-dev

# Copy the Gemfile and Gemfile.lock into the container
COPY Gemfile Gemfile.lock ./

# Install the gems listed in the Gemfile
RUN bundle install

# Copy the rest of the application code
COPY . .

# Expose the default Sinatra port
EXPOSE 4567

# Run the application
CMD ["ruby", "app.rb", "-o", "0.0.0.0"]
