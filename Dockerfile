# INGM Bioinformatics
#
# DESCRIPTION: Ensembl API
# VERSION               0.0.1
# CREDITS Thanks to Kieron Taylor http://www.ebi.ac.uk/about/people/kieron-taylor that helped in the creation and revision of the Official Installation instructions from http://www.ensembl.org/info/docs/api/index.html

FROM      ubuntu:14.04
MAINTAINER Raoul J.P. Bonnal <ilpuccio.febo@gmail.com>


RUN apt-get update --fix-missing && apt-get install -y inotify-tools nano wget curl rsync bc git git-core apt-transport-https libxml2 libxml2-dev libcurl4-openssl-dev openssl sqlite3 libsqlite3-dev gawk libreadline6-dev libyaml-dev autoconf libgdbm-dev libncurses5-dev automake libtool bison libffi-dev make m4 git build-essential software-properties-common

RUN cd /opt &&\
    git clone https://github.com/bioperl/bioperl-live.git &&\
    cd bioperl-live &&\
    git checkout bioperl-release-1-6-1


RUN cd /opt &&\
    git clone https://github.com/Ensembl/ensembl-git-tools.git &&\
    export PATH=$PWD/ensembl-git-tools/bin:$PATH &&\
    git ensembl --clone api

RUN cd /opt &&\
    git clone https://github.com/samtools/tabix &&\
    cd tabix &&\
    make &&\
    cd perl &&\
    perl Makefile.PL PREFIX=/opt/ &&\
    make &&\
    make install

RUN apt-get install -y libdbi-perl libdbd-mysql-perl libdbd-sqlite3-perl

RUN ln -s /opt/bioperl-live /opt/bioperl-1.6.1

RUN cd /opt &&\
    git clone https://github.com/Ensembl/ensembl-rest

RUN apt-get install -y libcatalyst-perl liblog-log4perl-perl libcatalyst-action-rest-perl libcatalyst-modules-perl libchi-perl libxml-writer-perl

ADD entrypoint.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 3000

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# Optionally the docker can be run as an application just setting the command
#ENTRYPOINT ["/usr/local/bin/entrypoint.sh", "/opt/ensembl-rest/script/ensembl_rest_server.pl"]

# Build the image
# docker build -t helios/ensembl-docker .
# Run the image as a container and because it does not store any data, remove it when exiting.
# The container run as an application
# docker run --rm -p 3000:3000 -ti helios/ensembl-docker /bin/bash

# If you run the docker as an application you can use the command line of the selected app software as if would be in your local environment.
# docker run --rm -p 3000:3000 -ti helios/ensembl-docker --help
