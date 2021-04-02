FROM mysql:8

RUN \
    apt-get update && \
    apt-get install -y \
        curl
RUN \
    curl -fsSL -o /usr/local/bin/dbmate https://github.com/amacneil/dbmate/releases/latest/download/dbmate-linux-amd64 && \
    chmod +x /usr/local/bin/dbmate

# Setting Container
WORKDIR /repo
