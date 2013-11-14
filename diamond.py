#!/usr/bin/env python
################################################################################
##
## Copyright 2013 Stefan Ellmauthaler, ellmauthaler@informatik.uni-leipzig.de
##                      Joerg Puehrer, puehrer@informatik.uni-leipzig.de
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
## diamond.py
##
import argparse
import configparser as cp
import os
import tempfile
import time
import sys
import subprocess as sp

version='0.11'

# default variables
encdir = "lib"
installdir = os.path.dirname(os.path.realpath(__file__))
gringo = "gringo"
gringo305 = "gringo"
clasp = "clasp"
claspD = "claspD"
eclipse = "eclipse"

# encoding filenames
enc = dict(
    tkk = "3KK.lp ",
    adm = "admissible.lp ",
    base = "base.lp ",
    cf = "cf.lp ",
    cmp = "complete.lp ",
    grd = "grounded.lp ",
    model = "model.lp ",
    op = "op.lp ",
    opsm = "opsm.lp ",
    prf = "preferred.lp ",
    pref = "pref.lp ",
    prefpy = "pref.py ",
    prio_trans = "prio_trans.lp ",
    repr_change = "repr_change.lp",
    stb = "stable.lp ",
    transformpl = "transform.pl ",
    transformpy = "transform.py ")


def getoptval(config,section,option,default):
    if config.has_option(section,option):
        return config.get(section,option)
    else:
        return default

def initvars(cfgfile):
    global installdir, gringo, gringo305,clasp,claspD,eclipse
    cfgfile = os.path.expandvars(os.path.expanduser(cfgfile))
    config = cp.ConfigParser()
    if os.path.exists(cfgfile):
        config.read_file(open(cfgfile))
        installdir = getoptval(config,"Path","installdir",installdir)
        gringo = getoptval(config,"Path","gringo",gringo)
        gringo305 = getoptval(config,"Path","gringo305",gringo305)
        clasp = getoptval(config,"Path","clasp",clasp)
        claspD = getoptval(config,"Path","claspD",claspD)
        eclipse = getoptval(config,"Path","eclipse",eclipse)
    else: #config file does not exist - create one
        config.add_section("Path")
        config.set("Path","installdir",installdir)
        config.set("Path","gringo", gringo)
        config.set("Path","gringo305", gringo)
        config.set("Path","clasp", clasp)
        config.set("Path","claspD", claspD)
        config.set("Path","eclipse", eclipse)
        config.write(open(cfgfile,'w'))

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
    parser.add_argument('-cfg', help='specify a config-file', action='store', dest='cfgfile', default='~/.diamond')
    group = parser.add_mutually_exclusive_group()
    group.add_argument('-pf','--transform_pform', help='acceptance functions are given as propositional formulas (translation using ASP)', action='store_true', dest='transformpform')
    group.add_argument('-pfe','--transform_pform_eclipse', help='acceptance functions are given as propositional formulas (translation using Eclipse Prolog)', action='store_true', dest='transformpformec')
    group.add_argument('-pfr','--transform_prio', help='transform a prioritized ADF before the computation', action='store_true', dest='transformprio')
    parser.add_argument('-all', '--all', help='compute all sets and models', action='store_true', dest='all')
    parser.add_argument('--version', help='prints the current version', action='store_true', dest='version')
    
    args=parser.parse_args()
    tmp=tempfile.NamedTemporaryFile(delete=True)
    instance=os.path.abspath(args.instance)
    initvars(args.cfgfile)
    claspstring = " 2> /dev/null | " + clasp + " 0 2> /dev/null"
    for el in iter(enc):
        enc[el] = installdir + "/" + encdir + "/" + enc[el]
    if args.version:
        print("==============================")
        print("DIAMOND version " + version)
        print("==============================")
    if args.transformpform:
        tmp2=tempfile.NamedTemporaryFile(mode='w+', encoding='utf-8', delete=True)
        instance = tmp2.name
        print("==============================")
        print("transforming pForm ADF using ASP...")
        sys.stdout.flush()
        with sp.Popen(gringo + " " + enc['repr_change'] + " " + os.path.abspath(args.instance) +  " |"+ clasp + " 0 ", shell=True,stdout=sp.PIPE) as p:
            sto = p.stdout
            i=1
            for byteLine in sto:
                line = byteLine.decode(sys.stdout.encoding).strip() 
                if "ci(" in line or "co(" in line:
                    tmp2.write(line.replace("constant", str(i)).replace(") l(","). l(").replace(") s(","). s(").replace(") co(","). co(").replace(") ci(","). ci(")+".\n")
                    i+=1
        tmp2.close()

    if args.transformpformec:
        tmp2=tempfile.NamedTemporaryFile(delete=True)
        instance = tmp2.name
        print("==============================")
        print("transforming pForm ADF using Eclipse...")
        sys.stdout.flush()
        #start = time.time()
        os.system(eclipse + " -b " + enc['transformpl'] + "-e main -- " + os.path.abspath(args.instance) + " " + instance)
        #os.system("./transform.sh " + os.path.abspath(args.instance) + " " + instance)
        #os.system("python transform.py --propositional " + os.path.abspath(args.instance) + " > " + instance)
        #elapsed = (time.time() - start)
        #elapsedstring = "%.3f" % (elapsed,)
        #print("transformation took " + elapsedstring  + " seconds")    
    if args.transformprio:
        
        tmp2 = tempfile.NamedTemporaryFile(delete=True)
        instance = tmp2.name
        print("==============================")
        print("transforming prioritized ADF...")
        sys.stdout.flush()
        start = time.time()
        wd = os.getcwd()
        os.chdir(installdir + "/" + encdir)
        os.system("python " + enc['transformpy'] + os.path.abspath(args.instance) + " > " + instance)
        os.chdir(wd)
        elapsed = (time.time() - start)
        elapsedstring = "%.3f" % (elapsed,)
        print("transformation took " + elapsedstring  + " seconds")    
    if args.cf or args.all:
        print("==============================")
        print("conflict free sets:")
        sys.stdout.flush()
        os.system("echo '#hide.#show in/1.' > " + tmp.name)
        os.system(gringo + " " + enc['base'] + enc['cf'] + instance + " " + tmp.name + claspstring) 
    if args.model or args.all:
        print("==============================")
        print("two-valued models")
        sys.stdout.flush()
        os.system("echo '#hide.#show in/1.' > " + tmp.name)
        os.system(gringo + " " + enc['base'] + enc['cf'] + enc['model'] + instance + " " + tmp.name + claspstring)
    if args.smodel or args.all:
        print("==============================")
        print("stable models:")
        sys.stdout.flush()
        os.system("echo '#hide.#show in/1.#show out/1.' > " + tmp.name)
        os.system(gringo + " " + enc['base'] + enc['cf'] + enc['model'] + enc['opsm'] + enc['tkk'] + enc['stb'] + instance + " " + tmp.name + claspstring)
    if args.admissible or args.all:
        print("==============================")
        print("admissible models:")
        sys.stdout.flush()
        os.system("echo '#hide.#show in/1.#show out/1.#show udec/1.' > " + tmp.name)
        os.system(gringo + " " + enc['base'] + enc['op'] + enc['adm'] + instance + " " + tmp.name + claspstring)
    if args.complete or args.all:
        print("==============================")
        print("complete models:")
        sys.stdout.flush()
        os.system("echo '#hide.#show in/1.#show out/1.#show udec/1.' > " + tmp.name)
        os.system(gringo + " " + enc['base'] + enc['op'] + enc['cmp'] + instance + " " + tmp.name + claspstring)
    if args.grounded or args.all:
        print("==============================")
        print("grounded model")
        sys.stdout.flush()
        os.system("echo '#hide.#show in/1.#show out/1.#show udec/1.' > " + tmp.name)
        os.system(gringo + " " + enc['base'] + enc['op'] + enc['tkk'] + enc['grd'] + instance + " " + tmp.name + claspstring)
    if args.preferred:# or args.all:
        print("==============================")
        print("preferred model:")
        sys.stdout.flush()
        os.system("echo '#hide.#show in/1.#show out/1.#show udec/1.' > " + tmp.name)
        os.system(gringo + " " + enc['base'] + enc['op'] + enc['adm'] + instance + " " + tmp.name + claspstring + " --outf=2 | python " + enc['prefpy']  + " | gringo - " + enc['pref']  + tmp.name + claspstring)
        
if __name__ == "__main__":
    main()
