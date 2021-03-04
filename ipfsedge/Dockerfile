FROM debian:buster as ipfsbuilder

ARG IPFS_VERSION=v0.6.0
ARG IPFS_CLUSTER_SERVICE_VERSION=v0.13.0
ARG IPFS_CLUSTER_CTL_VERSION=v0.13.0

ENV IPFS_URL https://dist.ipfs.io/go-ipfs/${IPFS_VERSION}/go-ipfs_${IPFS_VERSION}_linux-amd64.tar.gz
ENV IPFS_CLUSTER_SERVICE_URL https://dist.ipfs.io/ipfs-cluster-service/${IPFS_CLUSTER_SERVICE_VERSION}/ipfs-cluster-service_${IPFS_CLUSTER_SERVICE_VERSION}_linux-amd64.tar.gz
ENV IPFS_CLUSTER_CTL_URL https://dist.ipfs.io/ipfs-cluster-ctl/${IPFS_CLUSTER_CTL_VERSION}/ipfs-cluster-ctl_${IPFS_CLUSTER_CTL_VERSION}_linux-amd64.tar.gz

# Install Utility Packages
RUN apt-get update && \
    apt-get install -q -y --fix-missing \
        tar \
        wget && \
            apt-get clean && \
            rm -rf /var/lib/apt/lists/*

# Install IPFS
RUN set -x && \
    wget -c ${IPFS_URL} -O - | \
    tar -C /usr/local/bin/ -xz --strip-components=1 go-ipfs/ipfs && \
    ipfs --version

# Install IPFS Cluster
RUN set -x && \
    wget -c ${IPFS_CLUSTER_SERVICE_URL} -O - | \
    tar -C /usr/local/bin/ -xz --strip-components=1 ipfs-cluster-service/ipfs-cluster-service && \
    ipfs-cluster-service --version
RUN set -x && \
    wget -c ${IPFS_CLUSTER_CTL_URL} -O - | \
    tar -C /usr/local/bin/ -xz --strip-components=1 ipfs-cluster-ctl/ipfs-cluster-ctl && \
    ipfs-cluster-service --version

# Add Swarm Key
COPY ./secrets/swarm.key /root/.ipfs/swarm.key
RUN chmod 0400 /root/.ipfs/swarm.key && \
    chown root:root /root/.ipfs/swarm.key

# Add Init Script
COPY ipfs-start.bash /usr/local/bin/ipfs-start
RUN chmod 0755 /usr/local/bin/ipfs-start && \
    chown root:root /usr/local/bin/ipfs-start

EXPOSE 8080
ENTRYPOINT [ "ipfs-start" ]