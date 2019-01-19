# README

Main container, of my CI/CD Pipeline. This project goal is to provide containers linked which created our Pipeline.

## This repository

 *stack*: project

### Todo


### Set up

We assume that you have already installed on your local machine docker, docker-compose, docker-machine.
If not follow this [link](https://github.com/ghandalf/ci-cd-pipeline.git). And of course, maven and java.

You need to clone the project from the repository.

 git clone http://github.com/ghandalf/ci-cd-pipeline.git

On Ubuntu machine the update for docker-compose lead you to /usr/local/bin/docker-compose, in fact it as to go under /usr/bin/docker-compose.

1. Docker version 18.06.1-ce
2. docker-compose version 1.23.1
3. docker-machine version v0.16.0

If you want ot stay with docker-compose uses:
   docker-compose up    // to kill the process most of us will use ctrl+c, if you do that don't forget to execute the line below.
   docker-compose down

Once docker tools are install, on MAC and Linux you could use the script [service.sh].
I have created it to avoid hand writing. Some commands are long to type and error prone.

Use the script to pull images needed for the project. 

1. In a terminal move under analytic-stack project, that you have clone from gitlab repo.

2. Make sure that service.sh is executable: 
   * chmod 750 service.sh | chmod +x docker.sh
3. Execute:
   * ./service.sh pull # Will pull the images we need.
     * It will pull all containers for the project.
     * You are ready to go.
   * ./service.sh start swarm # Will start the stack or swarm.

Some usefuls commands

1. /service.sh info, Give you information of the swarm, including networking configuration.
2. /service.sh status, Will give you the status of each containers.

### Startup all containers

You will find some errors in the log file at startup. At least some of them are normal processs due
to ELK philosophy. A container is not aware of the others unless they are up and running for communication.

### Contribution guidelines

* Code review
* Other guidelines

### Technical advice

* Use https://cloud.google.com/knative/, could be very nice to have.

### Resources

* Repo owner: Francis Ouellet, <Ouellet.Francis@gmail.com>
* Community: I am to leasy for that
