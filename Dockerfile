FROM elixir:1.12.1-alpine AS builder

ARG MIX_ENV=prod
ARG PHOENIX_SUBDIR=apps/browser

ENV MIX_ENV=${MIX_ENV}
ENV SECRET_KEY_BASE=O3jujzwQKLAo4+fktwB+Ib2tXoC5mb+UOAsepKpb3IbQJslGbCaJxL1Mkc8vKCmn

RUN \
    apk update && \
    apk upgrade --no-cache && \
    apk add --no-cache \
    nodejs \
    yarn \
    git \
    build-base && \
    mix local.rebar --force && \
    mix local.hex --force

COPY . /app/

WORKDIR /app
RUN mix release discord

FROM elixir:1.12.1-alpine

RUN apk update && \
    apk add --no-cache tini && \
    apk add --no-cache \
    bash \
    openssl-dev

ENV REPLACE_OS_VARS=true
ENV MIX_ENV=prod

WORKDIR /app

COPY --from=builder app/_build/prod/rel/discord .

ENTRYPOINT ["/sbin/tini", "--"]

CMD ["bin/discord", "start"]