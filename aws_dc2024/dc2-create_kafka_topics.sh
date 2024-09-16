#!/bin/env bash
# Create kafka topics (queues) for domain crawl

if [[ -f $1 ]]; then source $1; else echo "Argument envfile missing"; exit 1; fi


docker run --net=dc_prereq_default ${KAFKA_IMAGE} kafka-topics.sh --bootstrap-server ${CRAWL_HOST_LAN_IP}:9094 --create --topic dc.crawled --replication-factor 1 --partitions 16 --config compression.type=snappy
docker run --net=dc_prereq_default ${KAFKA_IMAGE} kafka-topics.sh --bootstrap-server ${CRAWL_HOST_LAN_IP}:9094 --create --topic dc.inscope --replication-factor 1 --partitions 16 --config compression.type=snappy
docker run --net=dc_prereq_default ${KAFKA_IMAGE} kafka-topics.sh --bootstrap-server ${CRAWL_HOST_LAN_IP}:9094 --create --topic dc.tocrawl --replication-factor 1 --partitions 16 --config compression.type=snappy
