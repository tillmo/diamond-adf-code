#!/usr/bin/env python
import argparse
import os
import tempfile
import time
import sys

version='0.8'

def main():
    parser= argparse.ArgumentParser(description='Program to compute different models and sets for a given ADF')
    parser.add_argument('instance', help='Filename of the ADF instance', default='instance.dl')
    parser.add_argument('-cf', '--conflict-free', help='compute the conflict free sets', action='store_true', dest='cf')
    parser.add_argument('-m', '--model', help='compute the two-valued models', action='store_true', dest='model')
    parser.add_argument('-sm', '--stablemodel', help='compute the stable models', action='store_true', dest='smodel')
    parser.add_argument('-g', '--grounded', help='compute the grounded model', action='store_true', dest='grounded')
    parser.add_argument('-c', '--complete', help='compute the complete models', action='store_true', dest='complete')
    parser.add_argument('-a', '--admissible', help='compute the admissible models', action='store_true', dest='admissible')
    parser.add_argument('-p', '--preferred', help='compute the preferred model', action='store_true', dest='preferred')
    group = parser.add_mutually_exclusive_group()
    group.add_argument('--transform_pform', help='transform a pForm ADF before the computation', action='store_true', dest='transformpform')
    group.add_argument('--transform_prio', help='transform a prioritized ADF before the computation', action='store_true', dest='transformprio')
    parser.add_argument('-all', '--all', help='compute all sets and models', action='store_true', dest='all')
    parser.add_argument('--version', help='prints the current version', action='store_true', dest='version')
    
    args=parser.parse_args()
    tmp=tempfile.NamedTemporaryFile(delete=True)
    instance=os.path.abspath(args.instance)
    if args.version:
        print("==============================")
        print("DIAMOND version " + version)
        print("==============================")
    if args.transformpform:
        tmp2=tempfile.NamedTemporaryFile(delete=True)
        instance = tmp2.name
        print("==============================")
        print("transforming pForm ADF...")
        #start = time.time()
        os.system("./transform.sh " + os.path.abspath(args.instance) + " " + instance)
        #os.system("python transform.py --propositional " + os.path.abspath(args.instance) + " > " + instance)
        #elapsed = (time.time() - start)
        #elapsedstring = "%.3f" % (elapsed,)
        #print("transformation took " + elapsedstring  + " seconds")    
    if args.transformprio:
        
        tmp2 = tempfile.NamedTemporaryFile(delete=True)
        instance = tmp2.name
        print("==============================")
        print("transforming prioritized ADF...")
        start = time.time()
        os.system("python transform.py --prioritized " + os.path.abspath(args.instance) + " > " + instance)
        elapsed = (time.time() - start)
        elapsedstring = "%.3f" % (elapsed,)
        print("transformation took " + elapsedstring  + " seconds")    
    if args.cf or args.all:
        print("==============================")
        print("conflict free sets:")
        os.system("echo '#hide.#show in/1.' > " + tmp.name)
        os.system("gringo base.lp cf.lp " + instance + " " + tmp.name + " | clasp 0 2> /dev/null")
    if args.model or args.all:
        print("==============================")
        print("two-valued models")
        os.system("echo '#hide.#show in/1.' > " + tmp.name)
        os.system("gringo base.lp cf.lp model.lp " + instance + " " + tmp.name + " | clasp 0 2> /dev/null")
    if args.smodel or args.all:
        print("==============================")
        print("stable models:")
        os.system("echo '#hide.#show in/1.#show out/1.' > " + tmp.name)
        os.system("gringo base.lp cf.lp model.lp opsm.lp 3KK.lp stable.lp " + instance + " " + tmp.name + " | clasp 0 2> /dev/null")
    if args.grounded or args.all:
        print("==============================")
        print("grounded model")
        os.system("echo '#hide.#show in/1.#show out/1.#show udec/1.' > " + tmp.name)
        os.system("gringo base.lp op.lp 3KK.lp grounded.lp " + instance + " " + tmp.name + " | clasp 0 2> /dev/null")
    if args.complete or args.all:
        print("==============================")
        print("complete models:")
        os.system("echo '#hide.#show in/1.#show out/1.#show udec/1.' > " + tmp.name)
        os.system("gringo base.lp op.lp complete.lp " + instance + " " + tmp.name + " | clasp 0 2> /dev/null")
    if args.admissible or args.all:
        print("==============================")
        print("admissible models:")
        os.system("echo '#hide.#show in/1.#show out/1.#show udec/1.' > " + tmp.name)
        os.system("gringo base.lp op.lp admissible.lp " + instance + " " + tmp.name + " | clasp 0 2> /dev/null")
    if args.preferred:# or args.all:
        print("==============================")
        print("preferred model:")
        os.system("echo 'optimize(1,1,incl).' > " + tmp.name) 
        os.system('gringo_305 --reify admissible.lp preferred.lp op.lp base.lp ' + instance + ' | gringo_305 - metasp/{meta.lp,metaD.lp,metaO.lp} ' + tmp.name + ' | claspD 0')


if __name__ == "__main__":
    main()
