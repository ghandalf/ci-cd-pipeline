# README

The analytic-stack project has been created to organize our deployment and analytics data.

Some specification on the stack:

_**Kibana**_ allows us to organize our dashboards, visualizations, and other saved objects into meaningful categories. We can create spaces based on team, use case, individual, or any way we will choose. Kibana can hold many spaces, each have different sets of index patterns, visualizations, save search and dashboards. If we want to manage users access, Kibana offers this possibility, but this service is not free. 

_**Ingest nodes** were introduced in **Elasticsearch** 5.0 as a way to process documents in Elasticsearch prior to indexing. They allow simple architectures with minimum components, where applications send data directly to Elasticsearch for processing and indexing. This often simplifies getting started with the Elastic Stack, but will also scale out as data volumes grow._

_**Logstash** was one of the original components of the Elastic Stack, and has long been the tool to use when needing to parse, enrich or process data. Over the years, a great number of input, output and filter plugins have been added, making it an extremely flexible and powerful tool that can be made to work in a variety of different architectures._

```
One of the major differences between Logstash and ingest node is how data gets in and out.

As ingest node runs within the indexing flow in Elasticsearch, data has to be pushed to it through bulk or indexing requests. There must therefore be a process actively writing data to Elasticsearch. An ingest node is not able to pull data from an external source, such as a message queue or a database.

A similar restriction exists after the data has been processed - the only option is to index data locally into Elasticsearch.

Logstash, on the other hand, has a wide variety of input and output plugins, and can be used to support a range of different architectures. It can act as a server and accept data pushed by clients over TCP, UDP and HTTP, as well as actively pull data from e.g. databases and message queues. When it comes to output there is a wide variety of options available, e.g. message queues like Kafka and RabbitMQ or long-term data archival on S3 or HDFS.

Queuing data:
When sending data to Elasticsearch, whether it is directly or via an ingest pipeline, every client needs to be able to handle the case when Elasticsearch is not able to keep up or accept more data. This is what we refer to as applying back-pressure. If the data nodes are not able to accept data, the ingest node will stop accepting data as well.

Logstash is able to queue data on disk using its persistent queues feature, allowing Logstash to  provide at-least once delivery guarantees and buffer data locally through ingestion spikes. Logstash also supports integration with a number of different types of message queues, which allows a wide variety of deployment patterns to be supported.
```

_**APM**_ (Open Source Applicaiton Performance Monitoring) helps us _"identify bottlenecks and zero in on problematic changes at the code level"_. We get more efficient code and better customer experiences. APM has many features, like how our services or applications are interacting, find where latency issues are, and where we need to optimize our applications. The ultimate goal of performance monitoring is to supply end users with a top quality end-user experience.

At the time of writing this documentation, we didn't explore all the possibilities given by the ELK stack (Elasticsearch, Logstash, Kibana) [Logging, Metrics, Security analytics].

Project:

 - First release:
   - Put in place a microservice usable on Premise or Cloud architecture;
   - Add the microservice in his container thru a full ELK analytic stack;
   - Put in place beats use to monitor container health;
   - Put in place Syslog and use [Tripwire](https://www.tripwire.com/) to increase security on the stack;

 - Second release:
   - Add [Kafka](https://kafka.apache.org/) as the Stream data platform
   - Kafka is fast, scalable, and fault-tolerant, it is a publisher/subscriber messaging system.
   - It is designed as a distributed system and can store a high volume of data.
   - It has a multi-subscription system (same data consume multiple time).
   - It persists data to disk and can deliver messages in real-time or batch without performance degradation.
   - It has built-in redundancy uses for mission-critical data.

Why **Analytic-api** is not part of the main application? What are the advantages and desavantages having a microservice instead to be integrated in a monolic project? Remember a microservice is a piece of a system separated by responsibilities (roles).

_Advantages_

```bash
   - creation of a scalable microservice;
   - no impact on the main project;
   - runs in his process;
   - a lightweight communication thru RestApi;
   - is built around business capability;
   - is independently deployable by fully automated   
     deployment machinery;
   - has its specific job and not concern by others 
     applications;
   - is a decoupled service, could be recomposed and 
     configured to serve a different application;
   - has a fast delivery process;
   - fewer mistake, the system is small and easy to 
     maintain.
```

_Disadvantages_

```bash
   - Cross-cutting concerns with the others applications 
     (define traffic routing), in our case the URL and the 
     data structure;
   - Deploy on their Virtual Machine or Containers, it 
     needs a container fleet management tools;
```

While we had decided to use ELK to perform analytics work, it makes sense to have those in their container. Here are the links [Docker](https://success.docker.com/article/dev-pipeline) or [AWS Simple Microservice](https://docs.aws.amazon.com/aws-technical-content/latest/microservices-on-aws/simple-microservices-architecture-on-aws.html) where you can find best practice. Those best practices ensure the quality of our delivery in any environment from DEV to PROD.

## High level diagrams

Here is the Analytic stack, simple docker containers use to do analytics on the main application. The first step for the analytic infrastructure.
![Analytic-Stack](resources/images/architecture/stack/Analytic-ELK.png)

If we want to monitor our application and improve the quality of our code, here is the infrastructure diagram:
![Analytic Infrastructure With APM](resources/images/architecture/stack/Analytic-ELK-APM.png)

A more mature architecture that will help to analyze his user's behaviors or the producers. It will be allowed us to compare our data to the current market and, have data over time is represented in the following diagram:
![Analytic with Kafka](resources/images/architecture/stack/Analytic-ELK-APM-Kafka.png)

## This repository

*analytic-stack*: Docker stack project - uses to put all together for full deployment on Premise or Cloud.

### Set up

We assume that you have already installed on your local machine:
 [docker, docker-compose, docker-machine].

If not follow this [link](https://docs.docker.com/install/). And of course, maven and java. You need to clone the project from the repository.

 git clone http://gitlab.lochbridge.com/fouellet/analytic.git

On Ubuntu machine the update for docker-compose lead you to /usr/local/bin/docker-compose, in fact it as to go under /usr/bin/docker-compose.

1. Docker version 18.06.1-ce
2. docker-compose version 1.23.1
3. docker-machine version v0.16.0

```bash
If you want to stay with docker-compose uses:
   > docker-compose up
To kill the process, most of us will use CTRL+C if you do that do not
forget to execute the line below.
   > docker-compose down
```

Once docker tools are installed, on MAC and Linux you could use the script [service.sh].
I have created it to avoid handwriting. Some commands are long to type and error-prone.

Quick overview:

```bash
1. In a terminal move under the analytic-stack project, that you have cloned from the gitlab repo.
2. Make sure that service.sh file is executable: 
   * > chmod 750 service.sh | chmod +x docker.sh
3. You can use the script to pull images needed for the project. 
   * > ./service.sh pull # Will pull the images we need.
4. Or you can start the stack. It will pull the images automatically.
   * > ./service.sh start stack // it run on the current terminal to see the logs.
   * > ./service.sh stop stack  // you need another terminal to execute it. It does a gracefull shutdown.
```

Some usefuls commands

```bash

1. /service.sh info, Give you information of the swarm, including networking configuration.
2. /service.sh status, Will give you the status of each containers.
```

### Startup all containers

You will find some errors in the log file at startup. Most of them are normal due
to ELK philosophy. A container is not aware of the others unless they are up and running for communication.

### Contribution guidelines

- Code review
- Other guidelines

### Technical advice

- Use https://cloud.google.com/knative/, a nice to have.

### Resources

- Repo owner: Francis Ouellet <fouellet@dminc.com>
- Community: Slack channel TBD
