# Domain Crawler

####
* IMPORTANT: Scripts starting with 'z' are for development purposes and must not be used on a production service as they destroy data.
####

This repo contains the code required to operate the UKWA domain crawler. Each year's code is intended to be collected here - the current and only year captured currently is 2024, in the `aws_dc2024/` directory. The instructions below are expected to be run within the year directory - all command lines below will need to be amended to match the actual, corresponding files.


Before running the deploy script:
- Copy a past .env file and edit the values for this server.
- Ensure that the new .env file name includes this server's name so that it can be easily identified (e.g., `aws_dc2024_crawler08-prod.env`)
- Ensure that the `STORAGE_PATH` directory in the .env file exists and is owned by this user (not root). If it doesn't, the server probably isn't ready for the domain crawl deployment.


# Step 1: Initial server setup

By running the `dc0` script with the new .env file, a series of OS-level requirements are created or configured . Note that the primary directory - `STORAGE_PATH` - has to exist for this script to complete. This attempts to ensure that if extra volumes need to be created and mounted beforehand, this extra setup step is done before running this `dc0` script. For example,
* `./dc0-initialise.sh aws_dc2024_crawler08-prod.env`

Examining the `dc0` script will explain the performed actions.

## Crawler pre-requisities

There are several services that need to exist before the heritrix crawler is installed. These pre-requisities are installed via the `dc1` script and are detailed in the `dc1-docker-compose.yaml` file.

To deploy:
* `./dc1-deploy_aws_dc_prereq.sh aws_dc2024_crawler08-prod.env`

After `dc1` is run, the following services should be running:
- kafka, accepting input on port 9094
- kafka-ui, viewable at http://localhost:9000/, which should show the 'dc-cluster' Cluster exists. An active broker collector should exist under the Brokers dashboard
- clamav, should have multiple instances running, all using the same location for the virus databases
- prometheus, viewable at http://localhost:9191/graph The Status > Targets and Status > Service Discovery are especially useful to see the configured watchers and alerts

The kafka service is one of these pre-requisities. If the kafka queues haven't previously been created, then once the pre-requisities have deployed, the kafka queues (known as topics in Kafka) need to be created, by:
* `./dc2-create_kafka_topics.sh aws_dc2024_crawler08-prod.env`

Once `dc2` is run, the kafka queues should be listed under the Topics 'dc-cluster' dashboard


## Heritrix deployment

Once the pre-requisities have started, the heritrix crawler can be deployed. To do this, run:
* `./dc3-deploy_aws_dc_crawler.sh aws_dc2024_crawler08-prod.env`

Note that heritrix runs under a user account with ID 1001. This is because, within the heritrix container, heritrix runs under this account ID and requires to write a very small `dmesg` startup log into the `/h3-bin/` container directory. On the current deployment server, the 1001 account ID is used by the 'node_exporter' user, but the owner detail is not significant.

After `dc3` is run, the heritrix ui should be viewable (after accepting the https security alert that may appear) at https://localhost:8443/. The user and password are defined in the `domain-crawler-config` repo so not to be recorded in this public repo.

Note that the heritrix job name is still 'frequent'. This seems to be hard-coded into the heritrix build. As this shouldn't actually matter, it has been left as is. The generated warcs will be prefixed as defined in `dc3-docker-compose.yaml` so it will be clear where they came from. Plus, be aware that it can be very useful to observe heritrix running - this can be done via `docker -it exec <heritrix docker name> bash`.


## Starting heritrix

It should now be possible to start the heritrix crawler. After logging into the heritrix ui,
- As stated above, the available heritrix job is 'frequent'. Select this job
- Select 'build' to instigate the creation of this crawler job
- Select 'launch' this heritrix job
- Select 'unpause' to actually start the crawler
- It is a good idea to check the information on the job page at this stage. The crawl log should be viewable, though it should be empty at this point. The Configuration-referenced Paths should especially be checked, to see that they are all "expanded" (in the `crawler-beans.cxml` file, many values are injected from the `domain-crawler-config` repo .env file). If there are any unexpanded values (such as '${launch_id}', the deployment has not been configured correctly. Most, though not all, of the path links should work, though the corresponding pages should be empty.

### Checks
If all started as expected, there should be several useful sources to check:
- Prometheus should show four containers up and reporting to it - http://localhost:9191/graph?g0.expr=up
  - The key two are kafka and npld-dc-heritrix-workers (the other two are prometheus itself and the node_exporter of the host machine)
- All target states should be Up - localhost:9191/targets
- http://localhost:9191/graph?g0.expr=heritrix3_crawl_job_uris_total should show 10 'kinds' of heritrix worker jobs, with the jobname defined in the .env file 
