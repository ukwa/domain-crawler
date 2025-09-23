#!/bin/env bash
# Create kafka topics (queues) for domain crawl

if [[ -f $1 ]]; then source $1; else echo "Argument envfile missing"; exit 1; fi


docker run --net=dc_kafka_default ${KAFKA_IMAGE} kafka-topics.sh --bootstrap-server ${KAFKA_BOOTSTRAP_SERVERS} --create --topic dc.crawled --replication-factor 1 --partitions 16 --config compression.type=snappy
docker run --net=dc_kafka_default ${KAFKA_IMAGE} kafka-topics.sh --bootstrap-server ${KAFKA_BOOTSTRAP_SERVERS} --create --topic dc.inscope --replication-factor 1 --partitions 16 --config compression.type=snappy
docker run --net=dc_kafka_default ${KAFKA_IMAGE} kafka-topics.sh --bootstrap-server ${KAFKA_BOOTSTRAP_SERVERS} --create --topic dc.tocrawl --replication-factor 1 --partitions 16 --config compression.type=snappy
docker run --net=dc_kafka_default ${KAFKA_IMAGE} kafka-topics.sh --bootstrap-server ${KAFKA_BOOTSTRAP_SERVERS} --create --topic dc.discarded --replication-factor 1 --partitions 16 --config compression.type=snappy

echo -e "Completed -----------------------\n"
