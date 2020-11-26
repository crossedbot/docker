# Builds a Redis server with select modules; not to be confused with existing
# images from redislabs and/or redisfab

ARG REDIS_VERSION=6.0.9
ARG OS_NICKNAME=buster
ARG OS=debian:buster-slim
ARG ARCH=x64

ARG READIES_PATH=modules/readies
ARG REDISEARCH_PATH=modules/RediSearch
ARG REDISGEARS_PATH=modules/RedisGears

#-------------------------------------------------------------------------------
# Build Redis base
FROM redisfab/redis:${REDIS_VERSION}-${ARCH}-${OS_NICKNAME} AS redis

#-------------------------------------------------------------------------------
# Build Python base
FROM ${OS} AS pybuilder
ARG READIES_PATH
WORKDIR /build
COPY --from=redis /usr/local/ /usr/local/
ADD ${READIES_PATH}/. /build
RUN ./bin/getpy2

#-------------------------------------------------------------------------------
# Build RediSearch
FROM pybuilder AS rsbuilder

ARG OS_NICKNAME
ARG OS
ARG ARCH
ARG REDISEARCH_PATH

RUN echo "Building RediSearch for ${OS_NICKNAME} (${OS}) for ${ARCH}"
WORKDIR /build

ADD ${REDISEARCH_PATH}/. /build
RUN ./system-setup.py
RUN /usr/local/bin/redis-server --version
RUN make fetch SHOW=1
RUN make build SHOW=1

#-------------------------------------------------------------------------------
# Build RedisGears
FROM pybuilder AS rgbuilder

ARG OS_NICKNAME
ARG OS
ARG ARCH
ARG REDISGEARS_PATH

RUN echo "Building RedisGears for ${OS_NICKNAME} (${OS}) for ${ARCH}"
WORKDIR /build

ADD ${REDISGEARS_PATH}/. /build
RUN ./system-setup.py
RUN make fetch SHOW=1
RUN make all SHOW=1
RUN ./getver > artifacts/VERSION

#-------------------------------------------------------------------------------
# Build and run redis-server
FROM redisfab/redis:${REDIS_VERSION}-${ARCH}-${OS_NICKNAME}

RUN apt update && \
    apt-get install -y \
        git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /usr/lib/redis/modules
RUN mkdir -p /var/opt/redislabs/lib/modules /var/opt/redislabs/artifacts

COPY --from=rsbuilder /build/build/redisearch.so /usr/lib/redis/modules
COPY --from=rgbuilder /build/redisgears.so /usr/lib/redis/modules
COPY --from=rgbuilder /build/bin/linux-x64-release/python3_* \
    /var/opt/redislabs/modules/rg/python3/
COPY --from=rgbuilder /build/artifacts/ /var/opt/redislabs/artifacts

RUN cd /var/opt/redislabs/modules/rg/ && \
    ln -s python3 python3_`cat /var/opt/redislabs/artifacts/VERSION`

# install RedisGears utilities
RUN P_VERSION=`cat /var/opt/redislabs/artifacts/VERSION` && \
    /var/opt/redislabs/modules/rg/python3_${P_VERSION}/bin/python3 -m \
        pip install git+https://github.com/RedisGears/gears-cli.git && \
    /var/opt/redislabs/modules/rg/python3_${P_VERSION}/bin/python3 -m \
        pip install git+https://github.com/RedisGears/rgsync.git

CMD [ \
    "--loadmodule", "/usr/lib/redis/modules/redisearch.so", \
    "--loadmodule", "/usr/lib/redis/modules/redisgears.so"  \
]