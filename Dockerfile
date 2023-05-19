FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install yarn (yarnpkg in ubuntu:22.04 is broken and also nodejs is too old there)
RUN apt-get update
RUN apt-get install --no-install-recommends -y curl
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash -
RUN apt install --no-install-recommends -y nodejs npm
RUN npm i --global yarn

# Install system packages then clean up to minimize image size
RUN apt-get update \
 && apt-get install --no-install-recommends -y \
      build-essential \
      curl \
      default-jre-headless \
      file \
      libarchive-dev \
      libffi-dev \
      libgd-dev \
      libpq-dev \
      libsasl2-dev \
      libvips-dev \
      libxml2-dev \
      libxslt1-dev \
      locales \
      nodejs \
      postgresql-client \
      ruby3.0 \
      ruby3.0-dev \
      tzdata \
      unzip \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Install compatible Osmosis to help users import sample data in a new instance
RUN curl -OL https://github.com/openstreetmap/osmosis/releases/download/0.47.2/osmosis-0.47.2.tgz \
 && tar -C /usr/local -xzf osmosis-0.47.2.tgz

ENV DEBIAN_FRONTEND=dialog

# Setup app location
RUN mkdir -p /app
WORKDIR /app

# Install Ruby packages
ADD Gemfile Gemfile.lock /app/
RUN gem install bundler \
 && bundle install

# Install NodeJS packages using yarn
ADD package.json yarn.lock /app/
ADD bin/yarn /app/bin/
RUN bundle exec bin/yarn install
