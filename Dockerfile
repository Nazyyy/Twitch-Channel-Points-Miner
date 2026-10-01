FROM golang:1.24-alpine AS build

WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN go build -o twitch-miner .

FROM alpine:3.22

WORKDIR /app
COPY --from=build /app/twitch-miner /app/twitch-miner

RUN mkdir -p /data/cookies /data/log

CMD ["/app/twitch-miner", "-data-dir", "/data"]
