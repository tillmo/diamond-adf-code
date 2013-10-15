#!/usr/bin/env python
################################################################################
##
## Copyright 2013 Stefan Ellmauthaler, ellmauthaler@informatik.uni-leipzig.de
##
## This file is part of diamond.
##
## diamond is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## diamond is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with diamond.  If not, see <http://www.gnu.org/licenses/>.
##
################################################################################
##
## transform.py
##
import argparse
import os
import tempfile


def transform_main():
    parser=argparse.ArgumentParser(description='Transforms a pForm or preferred ADF into the extended acceptance model representation')
    parser.add_argument('instance', help='Filename of the pForm or preferred ADF which has to be transformed', default='instance.lp')
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument('--propositional',action='store_true', help='Transform a pForm ADF into the extended acceptance model representation', dest='prop')
    group.add_argument('--prioritized', action='store_true', help='Transform a prioritized ADF into the extended acceptance model representation', dest='prio')

    args=parser.parse_args()
    inst=os.path.abspath(args.instance)
    if args.prop:
        command='linkcomputation.lp trans2.lp '
    else:
        command='prio_trans.lp '
    transform(inst,command)
    
def transform(inst, command):
    i=0
    tmp=tempfile.NamedTemporaryFile(delete=True)
    tmp2=tempfile.NamedTemporaryFile(delete=True)
    tmp3=tempfile.NamedTemporaryFile(delete=True)
    os.system("echo '#hide c/1.' > " + tmp3.name)
    os.system("gringo " + command + inst + 
              " | clasp 0 --outf=1 | head --lines=-1 >" + tmp.name)
    #os.system("cat " + tmp.name + " | wc -l")
    f = open(tmp.name,'r')
    for line in f.readlines():
        i+=1
        os.system("echo 'c(" + str(i) + ")." + line + "' > " + tmp2.name)
        os.system("gringo trans_prep_merge.lp " + tmp2.name + 
                  " 2> /dev/null | clasp --outf=1 | head --lines=-1 >> " + tmp3.name)
    os.system("gringo " + tmp3.name + " 2> /dev/null | clasp --outf=1 | head --lines=-1")
if __name__ == "__main__":
    transform_main()
