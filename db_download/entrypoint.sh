#!/bin/bash

specie=$1
release=$2
subrelease=$3

if [ -z "$specie" ]; then
  echo "Please specify a specie, i.e. homo_sapiens"
  exit 1
fi

if [ -z "$release" ]; then
  echo "Please specify a release, i.e. 81"
  exit 1
fi

if [ -z "$subrelease" ]; then
  echo "Please specify the sub release, i.e. 38"
fi
# http://www.ensembl.org/info/docs/webcode/mirror/install/ensembl-data.html
# To install the Ensembl Data:

# 1) Download the directory in ftp.ensembl.org/pub/current/mysql for whatever organism you want to install.
# 2) Each table file is gzipped so unpack the data into working directories, keeping separate directories for each database.
#    For each database you have downloaded, cd into the database directory and perform steps 3-5. For illustration, we will 
#    use homo_sapiens_core_81_38 as the database - you need to change this appropriately for each database you install.    
#    Remember, you also need to download and install the multi-species databases.

# 3) Start a MySQL console session (see the Installing MySQL section above if necessary) and issue the command:
#       create database homo_sapiens_core_81_38;
# 4) Exit the console session, and issue the following command to run the ensembl SQL file, which should be in the directory 
#    where you unpacked the downloaded data. This creates the schema for the empty database you created in step 3.
#    Note that we are using the example MySQL settings of /data/mysql as the install directory, and mysqldba as the database 
#    user. Note that here mysqldba is a MySQL account with file access to the database, which is not the same as a system 
#    user. See the MySQL documentation for instructions on creating/administering users.

#       /data/mysql/bin/mysql -u mysqldba homo_sapiens_core_81_38 < homo_sapiens_core_81_38.sql

# 5) Load the data into the database structure you have just built with the following command.

#       /data/mysql/bin/mysqlimport -u mysqldba --fields_escaped_by=\\ homo_sapiens_core_81_38 -L *.txt

#    Note that owing to the nature of some of the data in Ensembl it has been necessary to escape the table fields when 
#    dumping the MySQL text files. Hence to import successfully, a field escape parameter needs to be specified when using 
#    mysqlimport


# /ftp is where the data are downloaded 
# /var/lib/mysql is where the MySQL database is located

# returning status
# message
function if_something_goes_wrong {
    local status=$1
    local message=$2
    if [ $status -ne 0 ]; then
        echo $message >&2
        exit $status
    fi
}


# dbname
# mysql_host_ip
function clone_ensembl_db {

  local dbname=$1
  local dbhost=$2
  local status=0
  local sourcedir=/ftp

  if [ ! -e ${sourcedir}/${dbname}.downloaded ]; then
    rsync -avP rsync://ftp.ensembl.org/ensembl/pub/release_${release}/mysql/${dbname} ${sourcedir}/ &&\
    touch ${sourcedir}/${dbname}.downloaded

    if_something_goes_wrong $? "Database ${dbname} can not be dowloaded correctly. Please check your internet connection, the name of the specie or the release number"
  fi 

  if [ ! -e ${sourcedir}/${dbname}.dbcreated ]; then
      mysql -u mysqldba -h ${dbhost} \
          -e "CREATE DATABASE IF NOT EXISTS \`${dbname}\` DEFAULT CHARACTER SET \`utf8\` COLLATE \`utf8_unicode_ci\`;" &&\
      touch ${sourcedir}/${dbname}.dbcreated
      if_something_goes_wrong $? "Database ${dbname} can not be created into MySQL."
  fi

  if [ ! -e ${sourcedir}/${dbname}.schemaloaded ]; then
      cd ${sourcedir}/${dbname} &&\
      gunzip ${dbname}.sql.gz &&\
      mysql -h ${dbhost} -u mysqldba ${dbname} < ${dbname}.sql &&\
      gzip ${dbname}.sql &&\
      touch ${sourcedir}/${dbname}.schemaloaded
      if_something_goes_wrong $? "Database ${dbname} schema can not be loaded into MySQL."
  fi

  if [ ! -e ${sourcedir}/${dbname}.dbloaded ]; then
      are_there_txts=$(ls ${sourcedir}/${dbname}/*.txt.gz &>/dev/null)
      if [ $? -eq 0 ]; then
        cd ${sourcedir}/${dbname} &&\
        gunzip *.txt.gz &&\
        mysqlimport -h ${dbhost} -u mysqldba --fields_escaped_by=\\ ${dbname} -L *.txt &&\
        gzip *.txt &&\
        touch ${sourcedir}/${dbname}.dbloaded
        if_something_goes_wrong $? "Database ${dbname} can not be loaded into MySQL."
      else
        echo "Database ${dbname} has no data to be loaded"
      fi
  fi

}


# Required all R expect where specified
for database in ensembl_ontology_${release} ensembl_website_${release} ensembl_accounts; do
  clone_ensembl_db ${database} ensembl-db
done


# By Specie
 for database in ${specie}_core_${release}_${subrelease} ${specie}_funcgen_${release}_${subrelease} ${specie}_otherfeatures_${release}_${subrelease} ${specie}_variation_${release}_${subrelease}; do
  clone_ensembl_db ${database} ensembl-db
 done


# ensembl_go_81
# multi-species




# Optional ensembl_compara_81 ensembl_ancestral_81
