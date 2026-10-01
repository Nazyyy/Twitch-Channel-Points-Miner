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

RUN mkdir -p /data/cookies /data/log /www \
    && printf 'OK\n' > /www/index.html

CMD ["sh", "-c", "\
if [ ! -f /data/config.json ]; then \
    cp /app/config.template.json /data/config.json; \
fi; \
sed -i 's/\"auto_update\"[[:space:]]*:[[:space:]]*true/\"auto_update\": false/' /data/config.json; \
busybox httpd -f -p 0.0.0.0:${PORT:-3000} -h /www >/dev/null 2>&1 & \
http_pid=$!; \
miner_pid=''; \
trap 'kill $miner_pid $http_pid 2>/dev/null || true; exit 0' TERM INT; \
while true; do \
    /app/twitch-miner -data-dir /data & \
    miner_pid=$!; \
    wait $miner_pid; \
    code=$?; \
    echo \"Miner exited with code $code, restarting in 5 seconds...\"; \
    sleep 5; \
done"]
