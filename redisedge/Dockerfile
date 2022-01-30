# Builds a Redis server with select modules; not to be confused with existing
# images from redislabs and/or redisfab

ARG REDIS_VERSION=6.2.5
ARG OS_NICKNAME=bullseye
ARG OS=debian:bullseye-slim
ARG ARCH=x64

ARG GIT_MODULES_PATH=.git/modules/redisedge/modules
ARG READIES_PATH=redisedge/modules/readies
ARG REDISEARCH_PATH=redisedge/modules/RediSearch
ARG REDISGEARS_PATH=redisedge/modules/RedisGears
ARG CPYTHON_PATH=redisedge/modules/cpython
ARG LIBEVENT_PATH=redisedge/modules/libevent
ARG HIREDIS_PATH=redisedge/modules/hiredis
ARG REDISTIMESERIES_PATH=redisedge/modules/RedisTimeSeries
ARG CONNECTORS_PATH=redisedge/connectors

#-------------------------------------------------------------------------------
# Build Redis base
FROM redisfab/redis:${REDIS_VERSION}-${ARCH}-${OS_NICKNAME} AS redis

#-------------------------------------------------------------------------------
# Build Python base
FROM ${OS} AS pybuilder
ARG GIT_MODULES_PATH
ARG READIES_PATH
WORKDIR /build
COPY --from=redis /usr/local/ /usr/local/
ADD ${READIES_PATH}/. /build/deps/readies/
ADD ${GIT_MODULES_PATH}/. /build/redisedge/.git/modules/
RUN ./deps/readies/bin/getpy2
RUN ./deps/readies/bin/getpy3

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
RUN sed -i "$(printf 's|%s|%s|g' \
	'^gitdir:.*' \
	'gitdir: \.\/redisedge\/\.git\/modules\/RediSearch')" ./.git
RUN sed -i -E "$(printf 's|%s|%s|g' \
	'(\.\.\/){5}redisedge\/modules\/RediSearch' \
	'..\/..\/..\/..\/')" ./redisedge/.git/modules/RediSearch/config
RUN ./sbin/system-setup.py
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
ARG CPYTHON_PATH
ARG LIBEVENT_PATH
ARG HIREDIS_PATH

RUN echo "Building RedisGears for ${OS_NICKNAME} (${OS}) for ${ARCH}"
WORKDIR /build

RUN apt update && \
	apt-get install -y maven && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*

ADD ${REDISGEARS_PATH}/. /build
RUN sed -i "$(printf 's|%s|%s|g' \
	'^gitdir:.*' \
	'gitdir: \.\/redisedge\/\.git\/modules\/RedisGears')" ./.git
RUN sed -i -E "$(printf 's|%s|%s|g' \
	'(\.\.\/){5}redisedge\/modules\/RedisGears' \
	'..\/..\/..\/..\/')" ./redisedge/.git/modules/RedisGears/config
ADD ${CPYTHON_PATH}/. /build/deps/cpython
RUN sed -i "$(printf 's|%s|%s|g' \
	'^gitdir:.*' \
	'gitdir: \.\/redisedge\/\.git\/modules\/cpython')" \
	./deps/cpython/.git
RUN sed -i -E "$(printf 's|%s|%s|g' \
	'(\.\.\/){5}redisedge\/modules\/cpython' \
	'..\/..\/..\/..\/deps\/cpython')" \
	./redisedge/.git/modules/cpython/config
ADD ${LIBEVENT_PATH}/. /build/deps/libevent
RUN sed -i "$(printf 's|%s|%s|g' \
	'^gitdir:.*' \
	'gitdir: \.\/redisedge\/\.git\/modules\/libevent')" \
	./deps/libevent/.git
RUN sed -i -E "$(printf 's|%s|%s|g' \
	'(\.\.\/){5}redisedge\/modules\/libevent' \
	'..\/..\/..\/..\/deps\/libevent')" \
	./redisedge/.git/modules/libevent/config
ADD ${HIREDIS_PATH}/. /build/deps/hiredis
RUN sed -i "$(printf 's|%s|%s|g' \
	'^gitdir:.*' \
	'gitdir: \.\/redisedge\/\.git\/modules\/hiredis')" \
	./deps/hiredis/.git
RUN sed -i -E "$(printf 's|%s|%s|g' \
	'(\.\.\/){5}redisedge\/modules\/hiredis' \
	'..\/..\/..\/..\/deps\/hiredis')" \
	./redisedge/.git/modules/hiredis/config
RUN ./system-setup.py
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
RUN sed -i "$(printf 's|%s|%s|g' \
	'^gitdir:.*' \
	'gitdir: \.\/redisedge\/\.git\/modules\/RedisTimeSeries')" ./.git
RUN sed -i -E "$(printf 's|%s|%s|g' \
	'(\.\.\/){5}redisedge\/modules\/RedisTimeSeries' \
	'..\/..\/..\/..\/')" ./redisedge/.git/modules/RedisTimeSeries/config
RUN ./system-setup.py
RUN make fetch SHOW=1
RUN make build SHOW=1

#-------------------------------------------------------------------------------
# Build and run redis-server
FROM redisfab/redis:${REDIS_VERSION}-${ARCH}-${OS_NICKNAME}

ARG ARCH
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

COPY --from=rsbuilder /build/bin/linux-${ARCH}-release/search/redisearch.so \
	${MODULES}
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
