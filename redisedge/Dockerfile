# Builds a Redis server with select modules; not to be confused with existing
# images from redislabs and/or redisfab

ARG REDIS_VERSION=6.0.9
ARG OS_NICKNAME=buster
ARG OS=debian:buster-slim
ARG ARCH=x64

ARG READIES_PATH=modules/readies
ARG REDISEARCH_PATH=modules/RediSearch
ARG REDISGEARS_PATH=modules/RedisGears
ARG REDISTIMESERIES_PATH=modules/RedisTimeSeries
ARG CONNECTORS_PATH=connectors

#-------------------------------------------------------------------------------
# Build Redis base
FROM redisfab/redis:${REDIS_VERSION}-${ARCH}-${OS_NICKNAME} AS redis

#-------------------------------------------------------------------------------
# Build Python base
FROM ${OS} AS pybuilder
ARG READIES_PATH
WORKDIR /build
COPY --from=redis /usr/local/ /usr/local/
ADD ${READIES_PATH}/. /build/readies/
RUN ./readies/bin/getpy2

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
# Build RedisTimeSeries
FROM pybuilder AS rtsbuilder

ARG OS_NICKNAME
ARG OS
ARG ARCH
ARG REDISTIMESERIES_PATH

RUN echo "Building RedisTimeSeries for ${OS_NICKNAME} (${OS}) for ${ARCH}"
WORKDIR /build

ADD ${REDISTIMESERIES_PATH}/. /build
RUN ./system-setup.py
RUN make fetch SHOW=1
RUN make build SHOW=1

#-------------------------------------------------------------------------------
# Build and run redis-server
FROM redisfab/redis:${REDIS_VERSION}-${ARCH}-${OS_NICKNAME}

ARG CONNECTORS_PATH

ENV MODULES /usr/lib/redis/modules
ENV ARTIFACTS /var/opt/redislabs/artifacts
ENV RG /var/opt/redislabs/modules/rg

RUN apt update && \
    apt-get install -y \
        git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p ${MODULES}
RUN mkdir -p ${ARTIFACTS}

COPY --from=rsbuilder /build/build/redisearch.so ${MODULES}
COPY --from=rgbuilder /build/redisgears.so ${MODULES}
COPY --from=rtsbuilder /build/bin/redistimeseries.so ${MODULES}

COPY --from=rgbuilder /build/bin/linux-x64-release/python3_* ${RG}/python3/
COPY --from=rgbuilder /build/artifacts/ ${ARTIFACTS}

RUN cd ${RG} && ln -s python3 python3_`cat ${ARTIFACTS}/VERSION`

# install RedisGears utilities
RUN P_VERSION=`cat ${ARTIFACTS}/VERSION` && \
    ${RG}/python3_${P_VERSION}/bin/python3 -m \
        pip install git+https://github.com/RedisGears/gears-cli.git && \
    ${RG}/python3_${P_VERSION}/bin/python3 -m \
        pip install git+https://github.com/RedisGears/rgsync.git

# add additional connectors
COPY ${CONNECTORS_PATH}/* /tmp/connectors/
RUN P_VERSION=`cat ${ARTIFACTS}/VERSION` \
    SITE_PACKAGES=${RG}/python3_${P_VERSION}/lib/python3.7/site-packages && \
    cp -r /tmp/connectors/* ${SITE_PACKAGES}/rgsync/Connectors/ && \
    rm -r /tmp/connectors

CMD [ \
    "--loadmodule", "/usr/lib/redis/modules/redisearch.so",     \
    "--loadmodule", "/usr/lib/redis/modules/redisgears.so",     \
    "--loadmodule", "/usr/lib/redis/modules/redistimeseries.so" \
]
