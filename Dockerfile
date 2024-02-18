FROM ruby:3.1.4-alpine3.18

MAINTAINER Andrew Kane <andrew@ankane.org>

ARG INSTALL_PATH=/app
ARG RAILS_ENV=production
ARG DATABASE_URL=postgresql://user:pass@127.0.0.1/dbname
ARG SECRET_TOKEN=dummytoken

RUN mkdir -p $INSTALL_PATH

WORKDIR $INSTALL_PATH

COPY . .

RUN apk add --update build-base gcompat git libpq-dev jemalloc && \
    gem install bundler && \
    bundle install && \
    bundle binstubs --all && \
    bundle exec rake assets:precompile && \
    rm -rf tmp && \
    apk del build-base git && \
    rm -rf /var/cache/apk/*

ENV LD_PRELOAD=/usr/lib/libjemalloc.so.2
ENV MALLOC_CONF='abort_conf:true,narenas:2,background_thread:true,thp:never,dirty_decay_ms:1000,muzzy_decay_ms:0'

ENV PORT 8080

EXPOSE 8080

CMD puma -C /app/config/puma.rb
