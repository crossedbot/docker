FROM node:latest

RUN apt update && \
    apt-get install -y git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*


COPY ./rgmonitor.bash /usr/local/bin/rgmonitor
RUN chmod 0755 /usr/local/bin/rgmonitor && \
    chown root:root /usr/local/bin/rgmonitor

WORKDIR /var/opt/
RUN git clone https://github.com/RedisGears/RedisGearsMonitor.git
RUN cd RedisGearsMonitor && npm install

ENTRYPOINT [ "rgmonitor" ]