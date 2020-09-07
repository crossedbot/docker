FROM node:latest

RUN npm install -g redoc-cli

COPY ./redoc-do.bash /usr/local/bin/redoc-do
RUN chmod 0755 /usr/local/bin/redoc-do && \
    chown root:root /usr/local/bin/redoc-do

ENTRYPOINT [ "redoc-do" ]