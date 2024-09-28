# Domain Crawler

####
* IMPORTANT: Scripts starting with 'z' are for development purposes and must not be used on a production service as they destroy data.
####

This repo contains the code required to operate the UKWA domain crawler. Each year's code is intended to be collected here - the current and only year recorded here currently is 2024, in the `aws_dc2024/` directory. The instructions below are expected to be followed within the year directory - all command lines below will need to be amended to match the actual, corresponding files. The code below are using the DC2024 values as examples.


Prior to beginning the setup of the domain crawler, ensure that the `domain-crawler-config` repo is available. Our standard path for production is `~/github/domain-crawler-config/`, but can be specified for local and/or development. The information within this repo should be checked to ensure it is accurate and appropriate for this domain crawl.


Before running the deploy script:
- Copy a past .env file and edit the values for this server.
- Ensure that the new .env file name includes this server's name so that it can be easily identified (e.g., `aws_dc2024_crawler08-prod.env`)
- Ensure that the `STORAGE_PATH` directory in the .env file exists and is owned by this user (not root). If it doesn't, the server probably isn't ready for the domain crawl deployment.
- Update the CRAWL_HOST_LAN_IP and CRAWL_HOST_WAN_IP to reflect the local environment. As these are based on the 2024 domain crawl that ran on AWS, the WAN_IP is the internet IP that external websites would see in their logs, the LAN_IP is the AWS internal network IP.
- Ensure the WARC_PREFIX is set appropriately. This is the most important identifier of from where crawl data is gathered so make sure this will be informative in future years.
- Ensure the HERITRIX_RAM is set. This value is used twice in the `dc3-docker-compose.yaml` file for Xms and Xmx. (This value being the same for both is fine, they represent the start value and the maximum that can be used.)


# Step 1: Initial server setup

By running the `dc0` script with the new .env file, a series of OS-level requirements are created or configured . Note that the primary directory - `STORAGE_PATH` - has to exist for this script to complete. This attempts to ensure that if extra volumes need to be created and mounted beforehand, this extra setup step is done before running this `dc0` script. For example,
* `./dc0-initialise.sh aws_dc2024_crawler08-prod.env`

Examining the `dc0` script will explain the performed actions.


## Crawler pre-requisities

There are several services that need to exist before the heritrix crawler is installed. These pre-requisities are installed via the `dc1` script and are detailed in the `dc1-docker-compose.yaml` file.

To deploy:
* `./dc1-deploy_aws_dc_prereq.sh aws_dc2024_crawler08-prod.env`

After `dc1` is run, the following services should be running:
- kafka, accepting container-internal input on port 9092 and local LAN input on port 9094
- kafka-ui, viewable at http://localhost:9000/, which should show the 'dc-cluster' Cluster exists. An active broker collector should exist under the Brokers dashboard
- clamav, should have multiple instances running, all using the same location for the virus databases
- prometheus, viewable at http://localhost:9191/graph The Status > Targets and Status > Service Discovery are especially useful to see the configured watchers and alerts

The kafka service is one of these pre-requisities. If the kafka queues haven't previously been created, then once the dc1 services have been deployed, the kafka queues (known as topics in Kafka) need to be created, by:
* `./dc2-create_kafka_topics.sh aws_dc2024_crawler08-prod.env`

Once `dc2` is run, the kafka queues should be listed under the Topics 'dc-cluster' dashboard


## Heritrix deployment

Once the crawler pre-requisities have started, the heritrix crawler can be deployed. To do this, run:
* `./dc3-deploy_aws_dc_crawler.sh aws_dc2024_crawler08-prod.env`

Note that heritrix runs under a user account with ID 1001. This is because, within the heritrix container, heritrix runs under this account ID and requires to write a very small `dmesg` startup log into the `/h3-bin/` container directory. On the current deployment server, the 1001 account ID is used by the 'node_exporter' user, but the owner detail is not significant. (If no local host user exists already, then the `heritrix` user is created.)

After `dc3` is run, the heritrix ui should be viewable (after accepting the https security alert that may appear) at https://localhost:8443/. The user and password are defined in the `domain-crawler-config` repo so not to be recorded in this public repo.

Note that the heritrix job name is still 'frequent'. This seems to be hard-coded into the heritrix build. As this shouldn't actually matter, it has been left as is. The generated warcs will be prefixed as defined in `dc3-docker-compose.yaml - WARC_PREFIX` so it will be clear where they came from. 


## Starting heritrix

It should now be possible to start the heritrix crawler. After logging into the heritrix ui,
- As stated above, the available heritrix job is 'frequent'. Select this job
- Select 'build' to instigate the creation of this crawler job
- Select 'launch' this heritrix job
- It is a good idea to check the information on the job page at this stage. The crawl log should be viewable, though it should be empty at this point. The Configuration-referenced Paths should especially be checked, to see that they are all "expanded" (in the `crawler-beans.cxml` file, many values are injected from the `domain-crawler-config` repo .env file). If there are any unexpanded values (such as '${launch_id}', the deployment has not been configured correctly. Most, though not all, of the path links should work, though the corresponding pages should be empty.

### Checks
If all started as expected, there should be several useful sources to check:
- Prometheus should show four containers up and reporting to it - http://localhost:9191/graph?g0.expr=up
  - The key two are kafka and npld-dc-heritrix-workers (the other two are prometheus itself and the node_exporter of the host machine)
- All target states should be Up - localhost:9191/targets
- http://localhost:9191/graph?g0.expr=heritrix3_crawl_job_uris_total should show 10 'kinds' of heritrix worker jobs (each value being 0), with the jobname defined in the .env file 
- To observe heritrix running, use `docker -it exec <heritrix docker name> bash`.
- The heritrix UI should also show links to`surtPrefixSeedScope` and `surtPrefixScopeExclusion`. If the `surt` files have not yet been added, the content of both of these should be empty.

## Submit a test seed

Before adding the appropriate surts and excluded-surts files, a test can be submitted to the crawler. To do so, run:
* `docker run --network=dc_kafka_default ukwa/crawl-streams:1.0.1 submit -k kafka-1:9092 -S dc.tocrawl <small website URL>`

There should not be any command line response, but within ~30 seconds a new entry in the kafka `dc.tocrawl` queue should appear. (*Be sure to wait long enough, it takes longer than expected*). Checking the Message in that queue should show the submitted URL. (If it does not, something is misconfigured.)

At this point, heritrix can be unpaused and it should crawl that seed, and only that seed because there is no acceptable scope defined as a surt. When heritrix has gathered the website seed content, it should be visible in the `dc.crawled` queue.

**Remember** to pause and checkpoint heritrix before continuing.

The local STORAGE_PATH/heritrix/output/... directory should now contain meaningful crawl.log.cp\* and warc.gz files that can be read to check the crawling ran as expected. (`zless` is great for viewing the warc.gz .)


## In-scope and excluded surts

Before running the crawler at scale, the 'in-scope' surts and the 'excluded' surts files need to be added. The two 'surts' files - `surts.txt` and `excluded-surts.txt` represent included and excluded domains to be crawled. The 'surts.txt' file is made up of the broad default values of:
```
+cymru
+london
+scot
+wales
+uk
```

plus the seeds that have been identified to match UKWA crawl criteria but are outside of these defaults. This latter information was previously collected in W3ACT prior to the BL cyber-attack as the list of NPLD-scope domain-crawl-frequency-only seeds.

Surt files should be in 'surt' format (see https://heritrix.readthedocs.io/en/latest/glossary.html?highlight=surt#glossary for understanding), and sorted in alphabetical order. If they are not already, there is a converter script in the `dc-seeds` repo.

**Note that the names of these 'surt' files is important - they need to match what is defined for SURTS_SOURCE_FILE and SURTS_EXCLUDE_SOURCE_FILE in the .env file**

#### UKWA in-scope surts file

For DC2024, the 'in-scope' surts file from the DC2022 AWS crawl has been used. Specifically, `dc-seeds$ cp dc-seeds-2022/surts-heritrix/excluded-surts.txt dc-seeds-2024/excluded-surts.txt`.

#### UKWA excluded surts file

The same approach has been taken for the 'excluded' surts file - specifically `cp dc-seeds-2022/surts-heritrix/surts.txt  dc-seeds-2024/surts.txt`.

### Submit surts to heritrix

Once the surts files have been created/updated as necessary, they are added to the crawler by:
* `source aws_dc2024_crawler08-prod.env && cp ~/github/dc-seeds/dc-seeds-2024/surts.txt ${HERITRIX_SURTS_PATH}/`
* `source aws_dc2024_crawler08-prod.env && cp ~/github/dc-seeds/dc-seeds-2024/excluded-surts.txt ${HERITRIX_SURTS_PATH}/`

This copies these two 'surts' .txt files into the heritrix surts directory, as defined in the .env file.

To check this important step has been 'picked up' by heritrix, check again the heritrix UI `surtPrefixSeedScope` and `surtPrefixScopeExclusion` links; these should now show the content of the surts files in the `dc-seeds/<year>` repo sub-directory. (Heritrix frequently checks the content in the surts directory inside the container (defined in the .env file) for changes.)


## Prepare Nominet seeds

The UK Web Archive have access to the Nominet ftp account, which provides a daily record of DNS domains etc. The tarball of data should be downloaded once, just before the beginning of the domain crawl. (I.e., it is not imperitive that the very latest data is used.) As of 2024, the tarball contains numerous lists of information, including a .csv dump of domains, in '<hostname>,<tld>' format (such as 'webarchive,org.uk' or 'bl,uk'. This list should be converted into seeds using the ` dc-seeds/common-scripts/nominet-generate-seeds.py` script. For example,
* `python ~/github/dc-seeds/common_scripts/nominet-generate-seeds.py db-dump-20240925.csv > nominet.domains.seeds`

## Submit domain crawl seeds

Before submitting the DC seeds, it is a good idea to make sure **the crawler is paused**. This isn't absolutely necessary - seeds are regularly added whilst the frequent crawler is running - but it may help to not overload kafka or the crawler.

**And, make sure the seeds file being submitted is in Unix format (not Windows).** To ensure this, convert via `dos2unix <winfile>`.

Seed lists do not need to be in 'surt' format and do not need to be sorted in any way. To submit, run:
* `./dc4-submit_seeds.sh <.env> <full path of seed list>`

This script submits the seeds file to the kafka `dc.tocrawl` queue. This will take some time to complete - the full Nominet list of 10 million seeds will take an hour or more. 

After a seed submission has started, set up log tailing if desired. The kafka queues should show progress over time, and the seeds should be viewable in the latest 'dc.crawl' messages.


## Pause and Shutdown processes

** IT IS ABSOLUTELY IMPERITIVE TO PAUSE AND CHECKPOINT THE CRAWLER BEFORE STOPPING FOR ANY REASON. **

* To pause the crawler
  - Use the UI and select 'Pause'. 
    This is likely to take a long time if the server is busy with many threads - give it as long as it needs, even if it is hours. If progress seems to have stopped (i.e., the server is idle and the heritrix logs show no activity) **STILL WAIT**. 
  - When the pause has completed, select 'checkpoint'. 
    If no checkpoint is successfully recorded, the next run will have to be from the previous checkpoint, and all state information will be lost. (Logically, any subsequent warcs created will remain.)

* To stop the crawler
  - After the pause and checkpoint have been completed, select 'terminate' in the heritrix ui.
  - Via the terminal, stop the crawler stack `docker stack rm <crawl stack name>`

Always allow time for each action to complete. Observe the logs if necessary to be confident of the status.

## Restarting crawling

As the domain crawler is currently using `docker`, this service is disabled from starting automatically on server boot (so to allow for any necessary remedial actions). When the server is ready to start crawling again, start docker by
* `sudo systemctl start docker`

Depending on the previous server state, docker may take 20+ minutes to start. Once completed and the server settles to low load, repeat the start up steps above (**ensuring no 'z' development scripts are used, and the kakfa queues need not be created again**).

As 'docker swarm' is currently used, once docker starts, the 'dc_kafka' services should already have started. (If not, use `dc1` as above to restart again.) Then start the crawler components using `dc3` as above.
