#!/bin/bash

##############################################################
# deployment script for diamond                              #
# creates a tarball with all required files for distribution #
##############################################################

cd ..
tar -cjf diamond.tar.bz2 diamond/README diamond/diamond.py diamond/lib/*
