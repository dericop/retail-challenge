FROM elixir:1.10.3-alpine
RUN apk add build-base
WORKDIR /app
COPY . /app
RUN mix local.hex --force \
    && mix local.rebar --force \
    && mix deps.get \
    && mix deps.compile \
    && MIX_ENV=prod mix distillery.release \
    && rm -rf /app/_build/prod/rel/retail_challenge/etc

FROM elixir:1.10.3-alpine
WORKDIR /app
EXPOSE 8083
RUN apk update && apk upgrade && apk add bash
COPY --from=0 /app/_build/prod /app
VOLUME /app/rel/retail_challenge/etc
ENTRYPOINT exec /app/rel/retail_challenge/bin/retail_challenge foreground
