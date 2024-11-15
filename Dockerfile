FROM ruby:3.3.6-alpine3.20

LABEL org.opencontainers.image.authors="Andrew Kane <andrew@ankane.org>"

ARG INSTALL_PATH=/app
ARG RAILS_ENV=production
ARG DATABASE_URL=postgresql://user:pass@127.0.0.1/dbname

RUN mkdir -p $INSTALL_PATH

WORKDIR $INSTALL_PATH

COPY . .

RUN apk add --update build-base gcompat git libpq-dev && \
    gem install bundler && \
    bundle install && \
    bundle binstubs --all && \
    bundle exec rake assets:precompile && \
    rm -rf tmp && \
    apk del build-base git && \
    rm -rf /var/cache/apk/*

ENV PORT=8080

EXPOSE 8080

CMD ["puma", "-C", "/app/config/puma.rb"]
