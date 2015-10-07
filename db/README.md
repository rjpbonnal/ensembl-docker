Running the Database
====================

Create your local db directories

    mkdir -p /yourpath/log
    mkdir -p /yourpath/mysql
    mkdir -p /yourpath/ftp

Build the docker
================

    git clone https://github.com/helios/ensembl-docker
    cd ensembl-docker/database
    docker build -t helios/ensembl-db .


Run the docker
==============

Run the docker images which setup the first instance of MySQL.
    

    docker run -p 5306:5306 -d --name ensembl-db -v /mnt/cdata/db/ensembl/log:/var/log/mysql -v /mnt/cdata/db/ensembl/mysql:/var/lib/mysql -v /mnt/cdata/db/ensembl/ftp:/ftp -e 'DB_REMOTE_ROOT_NAME=mysqldba' helios/ensembl-db

To initialize a database with the desired specie release and genome version see the Docker `db_download`