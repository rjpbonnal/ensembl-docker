# ensembl-docker
Ensembl Perl API on Docker

# Long Description
This is the complete installation of the Perl API from Ensembl following the official instruction reported http://www.ensembl.org/info/docs/api/index.html

# Docker as application
Optionally the docker can be run as an application just setting the command

    ENTRYPOINT ["/usr/local/bin/entrypoint.sh", "/opt/ensembl-rest/script/ensembl_rest_server.pl"]

# Building the image
    
    docker build -t helios/ensembl-api .

Run the image as a container and because it does not store any data, remove it when exiting. The container run as an application

    docker run --rm -p 3000:3000 -ti helios/ensembl-api /bin/bash

If you run the docker as an application you can use the command line of the selected app software as if would be in your local environment.
    
    docker run --rm -p 3000:3000 -ti helios/ensembl-api --help


    docker run --name ensembl-api -p 3000:3000 --link ensembl-db -d helios/ensembl-api
