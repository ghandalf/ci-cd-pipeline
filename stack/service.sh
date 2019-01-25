#!/bin/bash

###
## Use to stars current docker configs
##
## Author: fouellet@dminc.com
###
application=$0
command=$1
args=($2 $3 $4 $5 $6 $7 $8 $9 $10)
dt="\t\t"
version=

###
# Load properties files
##
function loadResources() {
	echo -e "\n${dt}Loading resources...";
	if [ -f .env ]; then
		source .env;
		version=${CONTAINERS_VERSION};
	else
		echo -e "\n${dt}${BRed}You need to provide .env file under root ./ directory...${Color_Off}\n";
	fi
	if [ -f ./resources/colors.properties ]; then
		source ./resources/colors.properties;
	else
		echo -e "\n${dt}${BRed}You need to provide colors.properties file under ./resources directory...${Color_Off}\n";
	fi
}

###
# Build container
##
function build() {
	local size=${#args[*]}; 
	if [[ $size > 0 ]] ; then
		for item in ${args[*]}; do
			docker build -f ./config/$item/Dockerfile -t ghandalf/$item:${CONTAINERS_VERSION} -t ghandalf/$item:latest .
		done
	else
		echo -e "\n${dt}${BRed}Nothing to build, list length: $size. ${Color_Off}\n";
	fi
}

###
# List all existing docker containers and related data.
#
##
function cleanup() {
	echo -e "\n${BGreen}Containers: \n${Yellow}`docker container ls`${Color_Off}\n";
	echo -e "\n${BGreen}Images: \n${Yellow}`docker image ls`${Color_Off}\n";
	echo -e "\n${BGreen}Volunes: \n${Yellow}`docker volume ls`${Color_Off}\n";
	echo -e "\n${BGreen}Network: \n${Yellow}`docker network ls`${Color_Off}\n";

	echo -e "\n${BRed}Stop all containers: \n${Yellow}`docker stop $(docker ps -aq)`${Color_Off}\n";
	echo -e "\n${BRed}Remove all containers: \n${Yellow}`docker rm $(docker ps -aq)`${Color_Off}\n";
	echo -e "\n${BRed}remove all images: \n${Yellow}`docker rmi $(docker images -aq)`${Color_Off}\n";

	echo -e "\n${On_IRed}Be careful now, read the instruction.${Color_Off}\n";
	echo -e "\n${BIRed}Prune: \n";
	docker system prune;
	echo -e "${Color_Off}\n";

	echo -e "\n${On_IRed}Be careful your volumes will be destroy, that include all indexex in Elasticsearch.${Color_Off}\n";
	echo -e "\n${BIRed}Prune all including volumes: \n";
	docker system prune --all --force --volumes;
	echo -e "${Color_Off}\n";
}

###
# Pull the images with the define version in .env files
#
#
function pull() {
    for i in "${images[@]}"; do
        docker pull $i;
    done
}


###
# This function will start the container by using command line for analytic, and 
# docker-compose.yml file for the swarm.
# Best practice is to use the swarm configuration.
##
function start() {
	# compose needs to shutdown all background processing before starting them.
	stopStack;
	clean;
	docker-compose -f $COMPOSE_FILE up;
}

function stopStack() {
	docker-compose -f $COMPOSE_FILE down;
	docker swarm leave --force;
	docker stop $(docker ps -qa);
}

function stop() {
	stopStack;
}

###
# Remove all containers, networks and force leaving the swarm due to manager container.
#
##
function clean() {
    echo -e "\n${dt}${Red}Removing background containers${Color_Off}";
	echo -e "${dt}${Red} Stopping containers `docker stop $(docker ps -aq)`${Color_Off}";
	echo -e "${dt}${Red} Removing containers `docker rm $(docker ps -aq)`${Color_Off}";
	#echo -e "${dt}${Red} Cleaning containers volumes `docker-compose down -v`${Color_Off}";

	#local result=`docker network ls --filter 'name=$analytic_network' | grep $analytic_network | awk {'printf $2'}`;
	#for network in "${networks[@]}"; do
	#	echo -e "${dt}${Red} Removing network: ${network} ${Color_Off}";
	#	docker network rm ${network};
	#done

	#docker swarm leave --force;
    echo -e "\n";
}

function info() {
	docker-compose -f $COMPOSE_FILE config;
	# docker-compose -f $compose_prod_file config;
	docker images;
	echo -e "\n";
	docker ps;
	echo -e "\n";
	docker network ls;
	#docker service ls;
	for container in `docker ps -a --format {{.Names}}`; do
		echo -e "\t${Yellow}$container${Color_Off} ip: [${Green}`docker container port $container`${Color_Off}]";
		echo -e "\t${Yellow}$container${Color_Off} log: [${Green}`docker inspect --format {{.LogPath}} $container`${Color_Off}]";
	done

	echo -e "\n\tIn case you need to install some tools in a container execute: \
	${Green}docker exec -u 0 -it heartbeat bash -c \"yum install nc\" \
	docker exec -u 0 -it heartbeat bash -c \"yum install -y net-tools iproute\" \
	to see the log of a container: docker logs -f containername${Color_Off}";
	echo -e "\n";
}

###
# Define how to use this script
##
function usage() {
    echo -e "\n\tUsage:";
    echo -e "${dt}$0 <info|clean|cleanup|start|stop>";
	echo -e "${dt}$0 ${On_IPurple} ATTENTION: using cleanup arguments could lead to data lost${Color_Off}";
	echo -e "\n";
}

loadResources;
case ${command} in
	build) 
		build $args ;;
	info)
		info $args ;;
	clean)
		clean $args ;;
	cleanup)
		echo -e "Not activated" ;;
	start)
		start $args ;;
	stop)
		stop $args ;;
    *) 
		usage ;;
esac
