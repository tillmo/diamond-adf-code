#!/bin/bash

##############################################################
# deployment script for diamond                              #
# creates a tarball with all required files for distribution #
##############################################################

cd ..
tar -cjf diamond.tar.bz2 diamond/README diamond/LICENSE diamond/diamond.py diamond/lib/*.py diamond/lib/*.lp diamond/lib/tools/*.lp diamond/lib/tools/*.py diamond/lib/adf2dadf/*.py
