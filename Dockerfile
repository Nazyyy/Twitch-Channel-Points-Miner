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

RUN mkdir -p /data/cookies /data/log

CMD ["sh", "-c", "if [ ! -f /data/config.json ]; then cp /app/config.template.json /data/config.json; fi; sed -i 's/\"auto_update\"[[:space:]]*:[[:space:]]*true/\"auto_update\": false/' /data/config.json; exec /app/twitch-miner -data-dir /data"]
