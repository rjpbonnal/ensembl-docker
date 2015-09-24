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
        echo message >&2
        exit $status
    fi
}


# dbname
function clone_ensembl_db {

  local dbname=$1
  local status=0

  if [ ! -e /ftp/${dbname}.downloaded ]; then
    rsync -avP rsync://ftp.ensembl.org/ensembl/pub/current_embl/${dbname} /ftp/ &&\
    touch ${dbname}.downloaded

    if_something_goes_wrong $? "Database ${dbname} can not be dowloaded correctly."

  else

    if [ ! -e /ftp/${dbname}.dbcreated ]; then
      create database homo_sapiens_core_81_38 &&\
      touch /ftp/${dbname}.dbcreated
      if_something_goes_wrong $? "Database ${dbname} can not be created into MySQL."
    fi

    if [ ! -e /ftp/${dbname}.schemaloaded ]; then
      cd /ftp/${dbname} &&\
      gunzip ${dbname}.sql.gz &&\
      mysql -u mysqldba ${dbname} < ${dbname}.sql &&\
      gzip ${dbname}.sql &&\
      touch /ftp/${dbname}.schemaloaded
      if_something_goes_wrong $? "Database ${dbname} schema can not be loaded into MySQL."
    fi

    if [ ! -e /ftp/${dbname}.dbloaded ]; then
      cd /ftp/${dbname} &&\
      mysqlimport -u mysqldba --fields_escaped_by=\\ ${dbname} -L *.txt &&\
      touch /ftp/${dbname}.dbloaded
      if_something_goes_wrong $? "Database ${dbname} can not be loaded into MySQL."
    fi
  fi

}


# Required all R expect where specified
for database in ensembl_ontology_81 ensembl_website_81 ensembl_accounts do
  clone_ensembl_db ${database}
done


# By Specie
# for database in homo_sapiens_core_81_38 homo_sapiens_funcgen_81_38 homo_sapiens_otherfeatures_81_38 homo_sapiens_variation_81_38 do
#   clone_ensembl_db ${database}
# done


# ensembl_go_81
# multi-species




# Optional ensembl_compara_81 ensembl_ancestral_81