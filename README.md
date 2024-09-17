# Domain Crawler

####
* IMPORTANT: Scripts starting with 'z' are for development purposes and must not be used on a production service as they destroy data.
####

This repo contains the code required to operate the UKWA domain crawler. Each year's code is intended to be collected here - the current and only year captured currently is 2024, in the `aws_dc2024/` directory. The instructions below are expected to be run within the year directory.


Before running the deploy script:
- Copy a past .env file and edit the values for this server.
- Ensure that the new .env file name includes this server's name so that it can be easily identified (e.g., `aws_dc2024_crawler08-prod.env`)
- Ensure that the `STORAGE_PATH` directory in the .env file exists and is owned by this user (not root). If it doesn't, the server probably isn't ready for the domain crawl deployment.


# Step 1: Initial server setup

By running the `dc0` script with the new .env file, the required directories will be created, the `clamav` user will be created, and the monitoring configs will be copied to their deployed directory location. Note that the primary directory - `STORAGE_PATH` - has to exist for this script to complete. This attempts to ensure that if extra volumes need to be created and mounted beforehand, this extra setup step is done before running this `dc0` script. For example,
* `./dc0-initialise.sh aws_dc2024_crawler08-prod.env`

## Crawler pre-requisities

There are several services that need to exist before the heritrix crawler is installed. These pre-requisities are installed via the `dc1` script and are detailed in the `dc1-docker-compose.yaml` file.

To deploy:
* `./dc1-deploy_aws_dc_prereq.sh aws_dc2024_crawler08-prod.env`

The kafka service is one of these pre-requisities. If the kafka queues haven't previously been created, then once the pre-requisities have deployed, the kafka queues (known as topics in Kafka) need to be created, by:
* `./dc2-create_kafka_topics.sh aws_dc2024_crawler08-prod.env`

Viewing the Kafka UI now should show **dc_cluster** under the Dasboard, and within this dc_cluster, 3 topics should exist for the domain crawl: dc.tocrawl, dc.inscope, and dc.crawled. There should also be a validated (green ticked) broker showing the EC2 internal IP.


## Heritrix deployment

Once the pre-requisities have started, the heritrix crawler can be deployed. To do this, run:
* `./dc3-deploy_aws_dc_crawler.sh aws_dc2024_crawler08-prod.env`

Note that heritrix runs under a user account with ID 1001. This is because, within the heritrix container, heritrix runs under this account ID and requires to write a very small `dmesg` startup log into the `/h3-bin/` container directory. On the current deployment server, the 1001 account ID is used by the 'node_exporter' user, but the owner detail is not significant.
