Running the Database
====================

Create your local db directories

    mkdir -p /yourpath/log
    mkdir -p /yourpath/mysql
    mkdir -p /yourpath/ftp

Run the docker images which setup the first instance of MySQL

    docker run -P --name mysql -v /mnt/cdata/db/ensembl/log:/var/log/mysql -v /mnt/cdata/db/ensembl/mysql:/var/lib/mysql -v /mnt/cdata/db/ensembl/ftp:/ftp -e 'DB_USER=mysqldba' -e 'DB_PASS=mysqldbapass' helios/mysql /bin/bash


Populate the DB with an ENSEMBL DB

    docker run --rm --link=ensembl-db -v /mnt/cdata/db/ensembl/ftp:/ftp -ti helios/ensembl-db /sbin/download_ensembl.sh homo_sapiens 81 38 &
