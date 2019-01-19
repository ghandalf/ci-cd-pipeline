#!/bin/bash

###
## Use to stars current docker configs
##
## Author: fouellet@dminc.com
###

application=$0
command=$1
args=($2 $3 $4)
dt="\t\t"
version=


###
# Load properties files
##
function loadResources() {
	# echo -e "\n${dt}$0 load resources...";
	if [ -f ./resources/docker.properties ]; then
		source ./resources/docker.properties;
		version=${application_version};
	else
		echo -e "\n${dt}${BRed}You need to provide docker.properties file under ./resources directory...${Color_Off}\n";
	fi
	if [ -f ./resources/colors.properties ]; then
		source ./resources/colors.properties;
	else
		echo -e "\n${dt}${BRed}You need to provide colors.properties file under ./resources directory...${Color_Off}\n";
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
##
function pull() {
    for i in "${images[@]}"; do
        docker pull $i;
    done
}

###
# Create or remove analytic network
##
function network() {
    local result=`docker network ls | grep ${analytic_network} | awk {'printf "%s\n", $2'}`;
	local exist_message="\n${dt}The docker network [${analytic_network}] already exists.";
    case $1 in
		create)
    		#echo -e "RESULT: $result";
    		if [ $result ]; then
        		echo -e $exist_message;
    		else 
        		echo -e "\n${dt}Creating docker network [${analytic_network}]";
        		docker network create ${analytic_network} --driver=bridge;
    		fi
			;;
		remove)
			if [ $result ]; then
				echo -e "\n${dt}Removing docker network [${analytic_network}]";
				docker network rm ${analytic_network};
			else
				echo -e "\n${dt}Docker network [${analytic_network}] doesn't exist.";
			fi
			;;
		*)
			echo -e "\n${dt}${BRed}Please you need to provide a sub command <create|remove>.${Color_Off}";
			;;
	esac
	docker network ls;
}


###
# This function will start the container by using command line for analytic, and 
# docker-compose.yml file for the swarm.
# Best practice is to use the swarm configuration.
##
function start() {
	case $1 in
		stack)
			# compose needs to shutdown all background processing before starting them.
			stopStack;
			clean;
			docker-compose -f $compose_file up;
			;;
		*)
			echo -e "\n${dt}${BRed}Please you need to provide a sub command <stack>.${Color_Off}";
			;;
	esac
}

function stopStack() {
	docker-compose -f $compose_file down;
	docker swarm leave --force;
	docker stop $(docker ps -qa);
}

function stop() {
	case $1 in
		stack)
			stopStack;
			;;
		*)
			echo -e "\n${dt}Please you need to provide a sub command <stack>";
			;;
	esac
}

###
# Remove all containers, networks and force leaving the swarm due to manager container.
#
##
function clean() {
    echo -e "\n${dt}${Red}Removing background containers${Color_Off}";
	# Those lines below remove the container for a specific stack, I will use them later.
	# for i in "${images[@]}"; do
	# 	local containerName=`echo $i | awk -F'/' {'printf $3'} | awk -F':' {'printf $1'}`;
    # 	docker stop $containerName;
    # 	docker rm $containerName;
	# done
	echo -e "${dt}${Red} Stopping containers `docker stop $(docker ps -aq)`${Color_Off}";
	echo -e "${dt}${Red} Removing containers `docker rm $(docker ps -aq)`${Color_Off}";
	echo -e "${dt}${Red} Cleaning containers volumes `docker-compose down -v`${Color_Off}";

	#local result=`docker network ls --filter 'name=$analytic_network' | grep $analytic_network | awk {'printf $2'}`;
	for network in "${networks[@]}"; do
		echo -e "${dt}${Red} Removing network: ${network} ${Color_Off}";
		docker network rm ${network};
	done

	docker swarm leave --force;
    echo -e "\n";
}

function info() {
	docker-compose -f $compose_file config;
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

function debugContainer() {
	local container="";
	local failure="false";
	case $1 in
		elasticsearch) container=elasticsearch;;
		filebeat) container=filebeat;;
		heartbeat) container=heartbeat;;
		kibana) container=kibana;;
		logstash) container=logstash;;
		metricbeat) container=metricbeat;;
		packetbeat) container=packetbeat;;
		*)
			echo -e "\n${dt}${Red}Please you need to provide a sub command <elasticsearch|filebeat|heartbeat|kibana|logstash|metricbeat|packetbeat>${Color_Off}";
			failure="true";
			;;
	esac
	if [ ${failure} == "false" ]; then
		docker exec -u 0 -it $container bash -c "./$container export config";
		docker exec -u 0 -it $container bash -c "./$container test output -e -d \"*\"";
	fi
}

function status() {
	case $args in
		long)
			# Kibana
			echo -e "\n${dt}${Yellow}Kibana${Color_Off} status: \n${Green}`curl -s -f localhost:5601/api/status`${Color_Off}";
			
			# ElasticSearch
			echo -e "\n${dt}${Yellow}ElasticSearch${Color_Off} status: \n${Green}`curl -s localhost:9200/`${Color_Off}";
			echo -e "${Green}`curl -s localhost:9200/_xpack/license`${Color_Off}";
			echo -e "${Green}`curl -XGET http://localhost:9200/_cluster/state?pretty`${Color_Off}";
			#echo -e "${Green}`curl -s -f -u elastic:changeme http://localhost:9200/_cat/health`${Color_Off}";

			# Logstash
			echo -e "\n${dt}${Yellow}Logstash${Color_Off} status: \n${Green}`curl -XGET "localhost:9600/?pretty"`${Color_Off}";
			echo -e "${Green}Logstash status [${Yellow}`netstat -na | grep 5044 | awk -F' ' NR==1{'printf"%s\n", $6'}`${Green}] on port 5044.${Color_Off}";
			echo -e "${Green}Logstash status [${Yellow}`netstat -na | grep 5000 | awk -F' ' NR==1{'printf"%s\n", $6'}`${Green}] on port 5000.${Color_Off}";
			;;
		short)
			# Kibana
			echo -e "\n${dt}${Yellow}Kibana${Color_Off} status: \n${Green}`curl -s -f localhost:5601/api/status`${Color_Off}";

			# ElasticSearch
			echo -e "\n${dt}${Yellow}ElasticSearch${Color_Off} status: \n${Green}`curl -s localhost:9200/`${Color_Off}";
			echo -e "\n${dt}${Yellow}ElasticSearch${Color_Off} status: \n${Green}`curl http://localhost:9200/_cat/indices?pretty`${Color_Off}";
			#for line in `curl http://localhost:9200/_cat/indices?pretty`; do
				#local status=echo $line | awk -F' ' {'printf "%s", $1'}
			#	echo -e "$line";
			#done
			
			# Logstash
			echo -e "\n${dt}${Yellow}Logstash${Color_Off} status [${Yellow}`netstat -na | grep 5044 | awk -F' ' NR==1{'printf"%s\n", $6'}`${Green}] on port 5044.${Color_Off}";
			echo -e "${dt}${Yellow}Logstash${Color_Off} status [${Yellow}`netstat -na | grep 5000 | awk -F' ' NR==1{'printf"%s\n", $6'}`${Green}] on port 5000.${Color_Off}";
			;;
		*)
			echo -e "\n${dt}${Red}Please you need to provide a sub command <long|short>${Color_Off}";
			failure="true";
			;;
	esac
}

###
# Create keystore and certificate
# We will need to use the customer certificate.
# At the end of this fucntion
# Edit the Hosts File
# 	Now you have a certificate that's valid for dev.dminc.com, so you'll need to use it in developement mode.
#   Open your hosts file (/private/etc/hosts on mac, /etc/hosts on linux) and add a new line like:
#	127.0.0.1       dev.dminc.com
#	Save the file. 
#	Now, while developing, have your dev server use the generated certificate files 
#	and develop against https://dev.dminc.com using whatever port numbers the server uses.
##
function setUpSecurity() {
	local ELASTIC_PASSWORD="changeme";
	local certificate="$ELASTIC_PASSWORD:-`openssl rand -base64 64`";
	echo -e "Certificate: $certificate";

	# passphrase used: dmiforcfna
	# Generate private key
	openssl genrsa -des3 -out config/ssl/ca/dmiCA.key 4096
	# Generate root certificate for 5 years
	openssl req -x509 -new -nodes -key config/ssl/ca/dmiCA.key -sha256 -days 1825 -out config/ssl/ca/dmiCA.pem

	# Generate a rsa file
	openssl genrsa -out config/ssl/ca/dev.dminc.com.key 4096
	# Generate the csr file
	openssl req -new -key config/ssl/ca/dev.dminc.com.key -out config/ssl/ca/dev.dminc.com.csr
	# Use the definition file: config/ssl/ca/dev.dminc.com.ext
	openssl x509 -req -in config/ssl/ca/dev.dminc.com.csr -CA config/ssl/ca/dmiCA.pem \
	-CAkey config/ssl/ca/dmiCA.key -CAcreateserial -out config/ssl/ca/dev.dminc.com.crt \
	-days 1825 -sha256 -extfile config/ssl/ca/dev.dminc.com.ext
}

###
# Container internal configuration, 
# This function is an helper for reminding how to connect and modify running container.
##
function configuration() {
	echo -e "\n${dt}${BRed}Not emplemented yet...${Color_Off}";
	echo -e "\n${dt}${BRed}Connect to a container as root: docker exec -u 0 -it <container_name> /bin/bash${Color_Off}";
	# docker exec -u 0 -it <container_name> /bin/bash
	# heartbeat -e -E logging.level=debug
}

###
# Use to connect as root to a specific container.
# Once the container is running
##
function bash() {
	local container="";
	local failure="false";
	local containerName=$1;
	local containerStatus=$2;
	local user=$3
	local process=/bin/bash;
	case $containerName in
		analytic) container=ghandalf/analytic-api;;
		elasticsearch) container=elasticsearch;;
		kafka) container=ghandalf/kafka;;
		kibana) container=kibana;;
		logstash) container=logstash;;
		proxy) container=ghandalf/proxy;;
		*)
			echo -e "\n${dt}${Red}1. Please you need to provide the container name <analytic|elasticsearch|kafka|kibana|logstash|proxy> and status <running|stop>${Color_Off}";
			failure="true";
			;;
	esac
	if [ ${failure} == "false" ]; then
		local value=`echo $container | awk -F'/' '{print $2}'` ;
		case $containerStatus in
			# connect as root user
			running)
				case user in
					root)
						if [ $value ]; then
							docker exec -u 0 -it $value ${process};
						else 
							docker exec -u 0 -it $container ${process};
						fi
						;;
					current)
						if [ $value ]; then
							docker exec -it $value ${process};
						else 
							docker exec -it $container ${process};
						fi
						;;
				esac
				;;
			# connect as current user
			stop)
				case user in
					root)
						if [ $value ]; then
							docker run -u 0 --rm -it --name $value $container ${process};
						else 
							docker run -u 0 --rm -it --name $container $container ${process};
						fi
						;;
					current)
						if [ $value ]; then
							docker run --rm -it --name $value $container ${process};
						else 
							docker run --rm -it --name $container $container ${process};
						fi
						;;
				esac
				;;
			*)
			echo -e "\n${dt}${Red}2. Please you need to provide the container name <elasticsearch|kafka|kibana|logstash|nginx> and status <running|stop>${Color_Off}";
			;;
		esac
	fi
}

###
# Inspect network information in the container.
##
function findContainerPort() {
	#echo -e "\n";
	#echo -e "\n${Yellow}`docker network inspect config_analytic_net`${Color_off}"
	
	#for containerId in `docker ps -a --no-trunc --format {{.ID}}`; do
	#	echo -e "\t\t${Blue}\
	#	`docker network inspect config_analytic_net --format "{{.Containers}}{{.Name}}"`${Color_off}";
	#	#echo -e "\n\t\t[${Yellow}`docker inspect $containerId`]${Color_off}"
	#done
	echo -e "\n${Yellow}`docker inspect --format='{{.Name}}\t{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $(docker ps -q)`${Color_Off}";
}

###
# Function use to validate the content docker-compose file
# It will not validate the specific container config file.
##
function validate() {
	case $1 in
		local)
			docker-compose -f ${compose_file} config;
			## Go to heach container and call ./metricbeat test config
			local command="";
			for container in `docker ps -a --format "{{.Names}}"`; do
				case $container in
					metricbeat|heartbeat|packetbeat|filebeat)
						command="$container test config";;
					logstash)
						command="$container --config.test_and_exit";;
					kibana|elasticsearch)
						command="none";;
					*)
						echo -e "\n\t${Red} Unkonwn container: [$container] ${Color_Off}";
				esac

				if [ ! "$command" = "none" ]; then
					echo -e "\n${Green} Test the config for [$container] container: \
					${Yellow}`docker exec -u 0 -it $container bash -c \"$command\"` ${Color_Off}";
				fi
			done 
			;;
		prod)
			docker-compose -f ${compose_prod_file} config;
			;;
		*)
			echo -e "\n${dt}${BRed}Please you need to provide argument <local|prod>.${Color_Off}";
		;;
	esac
}

###
# Update docker, docker-machine and docker-compose on any container manager.
# This function must be used for docker management only.
# FIXME: activate this function when all containers are ready for deployment.
##
function update() {
	case $args in
		docker)
			echo -e "\n${dt}${Green}docker version [${Red}`docker --version`${Green}] \n" \
				"${dt}docker-compose [${Red}`docker-compose --version`${Green}] \n" \
				"${dt}docker-machine [${Red}`docker-machine --version`${Green}] \n" \
				"${dt}will be updated with the latest release. \n" \
				"${dt}Important note we are running in experimental mode: [${Red}'`docker version -f {{.Server.Experimental}}`'${Green}] \n" \
				"${dt}If true, ${Yellow}you will have to change the value when you go in production.${Color_Off}";

			local OS=`uname -s`;
			case $OS in 
				Darwin)
					curl -L ${docker_compose_url}/${docker_compose_version}/docker-compose-`uname -s`-`uname -m` > ${docker_mac_path}/docker-compose && 
							chmod +x ${docker_mac_path}/docker-compose
					
					curl -L ${docker_machine_url}/${docker_machine_version}/docker-machine-`uname -s`-`uname -m` > ${docker_mac_path}/docker-machine && 
							chmod +x ${docker_mac_path}/docker-machine
					;;
				linux)
					echo -e "\nLINUX: curl -L ${docker_compose_url}/${docker_compose_version}/docker-compose-`uname -s`-`uname -m` > /tmp/docker-compose && 
						chmod +x /tmp/docker-compose &&
						sudo cp /tmp/docker-compose ${docker_linux_path}/docker-compose"

					echo -e "\nLINUX: curl -L ${docker_machine_url}/${docker_machine_version}/docker-machine-`uname -s`-`uname -m` > /tmp/docker-machine && 
						chmod +x /tmp/docker-machine &&
						sudo cp /tmp/docker-machine ${docker_linux_path}/docker-machine"
					;;
				windows)
					echo -e "\nWINDOWS: if [[ ! -d '${docker_windows_path}' ]]; then mkdir -p '${docker_windows_path}'; fi && 
						curl -L ${docker_compose_url}/${docker_compose_version}/docker-compose-Windows-x86_64.exe > '${docker_windows_path}/docker-compose.exe' && 
						chmod +x '${docker_windows_path}/docker-compose.exe'"
					
					echo -e "\nWINDOWS: if [[ ! -d '${docker_windows_path}' ]]; then mkdir -p '${docker_windows_path}'; fi && 
						curl -L ${docker_machine_url}/${docker_machine_version}/docker-machine-Windows-x86_64.exe > '${docker_windows_path}/docker-machine.exe' && 
						chmod +x '${docker_windows_path}/docker-machine.exe'"
					;;
			esac
			;;
		*)
			echo -e "\n${dt}${BRed}Please you need to provide argument <docker>.${Color_Off}";
			;;
	esac
}

###
# Internal diagnostic of the containers
##
function diagnose() {
	${docker_diagnose} gather
}


###
# Create a new container using Dockerfile under config directory
##
function createContainer() {
	local command=$1;
	local version=$2;
	if [ ! $version ]; then
		command="error";
	fi
	local versionSplit=($(echo "$version" | tr '.' '\n'))
	local previousVersion=${versionSplit[0]}.${versionSplit[1]}.$((${versionSplit[2]} - 1));
	echo -e "Current version: ${version}, previous version: ${previousVersion}";

	case $command in
		analytic)
			# Clean up the previous image
			docker rmi ghandalf/analytic-api:${previousVersion}
			docker rmi ghandalf/analytic-api

			echo "version=$version" > ./config/analytic-api/version.properties;

			docker build -f ./config/analytic-api/Dockerfile -t ghandalf/analytic-api:$version -t ghandalf/analytic-api:latest .
			;;
		kafka)
			# Clean up the previous image
			docker rmi ghandalf/kafka:${previousVersion}
			docker rmi ghandalf/kafka

			echo "version=$version" > ./config/kafka/version.properties;

			# need to update the Dockerfile with the current version
			# sed -i -e 's/^(ENV[[:blank:]]CONTAINER_VERSION[[:blank:]]*[[:blank:]]*).*/\ENV CONTAINER_VERSION 0.2.4/' config/kafka/Test
			docker build -f ./config/kafka/Dockerfile -t ghandalf/kafka:$version -t ghandalf/kafka:latest .
			;;
		proxy)
			# Clean up the previous image
			docker rmi ghandalf/proxy:${previousVersion}
			docker rmi ghandalf/proxy

			echo "version=$version" > ./config/proxy/version.properties;
			docker build -f ./config/proxy/Dockerfile -t ghandalf/proxy:$version -t ghandalf/proxy:latest .
			;;
		*)
			echo -e "\n${dt}${BRed}Please you need to provide two arguments first: <analytic|kafka|proxy>, second: <version>.${Color_Off}";;
	esac
}

###
# Publish the artifact to docker hub
##
function pushImage() {
	# using https://hub.docker.com/u/ghandalf
	local command=$1;
	docker login --username=ghandalf

	case $command in
		analytic)
			source config/analytic-api/version.properties	
			docker push ghandalf/analytic-api;
			;;
		kafka)
			source config/kafka/version.properties
			docker push ghandalf/kafka;
			;;
		proxy)
			source config/proxy/version.properties	
			docker push ghandalf/proxy;
			;;
		*)
			echo -e "\n${dt}${BRed}Please you need to provide two arguments first: <analytic|kafka|proxy>.${Color_Off}";;
	esac
}

###
# Define how to use this script
##
function usage() {
    echo -e "\n\tUsage:";
    echo -e "${dt}$0 <cleanup|pull|clean|start|stop|clean|info|status|validate|security>";
	echo -e "${dt}$0 ${On_IPurple} ATTENTION: using cleanup arguments could lead to data lost${Color_Off}";
	echo -e "\n";
}

###
# Will be implemented at the end, if we need to free resources.
##
function finish() {
	echo -e "";
	#echo -e "\n${dt}${Cyan}Function finish() is not implemented yet. Will be a graceful shutdown process...${Color_Off}\n";
}
trap finish EXIT;

loadResources;

## TODO: use getOpt instead of validate each entrances
case ${command} in
	bash)
		bash ${args[0]} ${args[1]} ${args[2]};;
	clean)
		clean;;
	cleanup)
		cleanup;;
	create)
		createContainer ${args[0]} ${args[1]};;
	info)
		info;;
	pull)
		pull;;
	push)
		pushImage ${args[0]} ${args[1]};;
	validate)
		validate ${args[0]};;
	start)
		start $args;;
	status)
		status $args;;
	stop)
		stop $args;;
	# debug)
	# 	debugContainer $args;;
	# diagnose)
	# 	diagnose;;
	# network)
	# 	network $args;;
	# port)
	# 	findContainerPort;;
	# security)
	# 	setUpSecurity;;
	# update)
	# 	update $args;;
    *) 
		usage;;
esac
