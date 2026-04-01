# syntax = docker/dockerfile:1

# This Dockerfile is designed for production, not development. Use with Kamal or build'n'run by hand:
# docker build -t my-app .
# docker run -d -p 80:80 -p 443:443 --name my-app -e RAILS_MASTER_KEY=<value from config/master.key> my-app

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version
# syntax=docker/dockerfile:1
ARG RUBY_VERSION=3.4.7
FROM ruby:${RUBY_VERSION}-slim AS base

ARG NODE_VERSION=22.22.2
ARG PNPM_VERSION=10.33.0

WORKDIR /rails

# 共通パッケージ
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      curl default-mysql-client libjemalloc2 libvips build-essential \
      default-libmysqlclient-dev git libyaml-dev node-gyp pkg-config python-is-python3 && \
    rm -rf /var/lib/apt/lists/*

# Node + pnpm
ENV PATH=/usr/local/node/bin:$PATH
RUN curl -sL https://github.com/nodenv/node-build/archive/master.tar.gz | tar xz -C /tmp/ && \
    /tmp/node-build-master/bin/node-build "${NODE_VERSION}" /usr/local/node && \
    npm install -g pnpm@"${PNPM_VERSION}" && \
    rm -rf /tmp/node-build-master

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY package.json pnpm-lock.yaml ./
RUN pnpm install

COPY . .

# ----------------------------------------------------------------
# --- development ---
# ----------------------------------------------------------------
FROM base AS development

ARG RAILS_ENV=development
ENV RAILS_ENV=${RAILS_ENV} \
    BUNDLE_PATH=/usr/local/bundle

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile

# ----------------------------------------------------------------
# --- production ---
# ----------------------------------------------------------------
FROM base AS production

ARG RAILS_ENV=production
ENV RAILS_ENV=${RAILS_ENV} \
    BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_DEPLOYMENT=1 \
    BUNDLE_WITHOUT=development:test

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile --prod

COPY . .

RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile && \
    rm -rf node_modules

# ユーザー作成
RUN groupadd --system --gid 1000 rails && \
    useradd --uid 1000 --gid 1000 --create-home --shell /bin/bash rails && \
    chown -R rails:rails /rails

USER rails

ENTRYPOINT ["/rails/bin/docker-entrypoint"]
EXPOSE 3000

CMD ["bin/rails", "server", "-b", "0.0.0.0"]
