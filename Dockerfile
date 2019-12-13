FROM ruby:2.6.2-slim

LABEL maintainer Travis CI GmbH <support+travis-live-docker-images@travis-ci.com>

# packages required for bundle install
RUN ( \
   apt-get update ; \
   apt-get install -y --no-install-recommends git make gcc g++ \
   && rm -rf /var/lib/apt/lists/* \
)

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1;
RUN mkdir -p /app
WORKDIR /app

COPY Gemfile       /app
COPY Gemfile.lock  /app

RUN gem install bundler -v '2.0.1'
RUN bundle install --deployment --without development test

# Copy app files into app folder
COPY . /app

CMD bundle exec puma -C lib/travis/yml/web/puma.rb