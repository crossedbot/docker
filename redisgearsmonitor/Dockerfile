FROM node:latest

RUN apt update && \
    apt-get install -y git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /var/opt/
RUN git clone https://github.com/RedisGears/RedisGearsMonitor.git
RUN cd RedisGearsMonitor && npm install

ENTRYPOINT [ "node", "/var/opt/RedisGearsMonitor/main.js" ]