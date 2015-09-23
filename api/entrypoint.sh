#!/bin/bash

set -e 

PERL5LIB=${PERL5LIB}:/opt/bioperl-1.6.1
PERL5LIB=${PERL5LIB}:/opt/ensembl/modules
PERL5LIB=${PERL5LIB}:/opt/ensembl-compara/modules
PERL5LIB=${PERL5LIB}:/opt/ensembl-variation/modules
PERL5LIB=${PERL5LIB}:/opt/ensembl-funcgen/modules
PERL5LIB=${PERL5LIB}:/opt/ensembl-io/modules
PERL5LIB=${PERL5LIB}:/opt/lib/perl/5.18.2/
PERL5LIB=${PERL5LIB}:/opt/ensembl-rest/modules

export PERL5LIB

PATH=${PATH}:/opt/tabix/
export PATH

"$@"