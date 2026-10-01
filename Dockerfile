FROM golang:1.24-alpine AS build

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN go build -o twitch-miner .

FROM alpine:3.22

WORKDIR /app

COPY --from=build /app/twitch-miner /app/twitch-miner
COPY config.json /app/config.template.json

RUN apk add --no-cache ca-certificates tzdata \
    && update-ca-certificates \
    && mkdir -p /data/cookies /data/log

CMD ["sh", "-c", "\
if [ ! -f /data/config.json ]; then \
    cp /app/config.template.json /data/config.json; \
fi; \
if [ -n \"$TWITCH_COOKIE_B64\" ]; then \
    echo \"$TWITCH_COOKIE_B64\" | base64 -d > /data/cookies/Nazy_33.json; \
    chmod 600 /data/cookies/Nazy_33.json; \
fi; \
exec /app/twitch-miner -data-dir /data"]
