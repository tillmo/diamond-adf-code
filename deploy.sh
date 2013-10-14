#!/bin/bash

##############################################################
# deployment script for diamond                              #
# creates a tarball with all required files for distribution #
##############################################################

tar -cjf diamond.tar.bz2 {3KK,base,cf,complete,model,op,opsm,preferred,prio_trans,stable,trans_prep_merge,admissible,grounded}.lp README transform.pl *.py metasp/* transform.sh
