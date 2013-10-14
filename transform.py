#!/usr/bin/env python
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
