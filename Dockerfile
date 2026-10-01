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

CMD ["sh", "-c", "\
echo \"COOKIE ENV LENGTH: ${#TWITCH_COOKIE_B64}\"; \
mkdir -p /data/cookies; \
if [ -n \"$TWITCH_COOKIE_B64\" ]; then \
    echo \"$TWITCH_COOKIE_B64\" | base64 -d > /data/cookies/Nazy_33.json; \
    echo \"COOKIE FILE SIZE: $(wc -c < /data/cookies/Nazy_33.json)\"; \
    echo \"COOKIE FILE: $(test -f /data/cookies/Nazy_33.json && echo EXISTS || echo MISSING)\"; \
else \
    echo \"COOKIE ENV: MISSING\"; \
fi; \
echo \"DATA CONTENT:\"; \
ls -lah /data/cookies; \
sleep 10"]
