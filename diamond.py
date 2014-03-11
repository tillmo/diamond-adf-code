#!/usr/bin/env python
################################################################################
##
## Copyright 2013 Stefan Ellmauthaler, ellmauthaler@informatik.uni-leipzig.de
##                Joerg Puehrer, puehrer@informatik.uni-leipzig.de
##                Hannes Strass, strass@informatik.uni-leipzig.de
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
## diamond.py
##
import argparse
import configparser as cp
import os
import tempfile
import time
import sys
import subprocess as sp
import lib.tools.formulatree as ft
import lib.adf2dadf.adf2dadf_adm as adf2dadf_adm
import lib.tools.utils as util

version='0.15'

# default variables
encdir = "lib"
installdir = os.path.dirname(os.path.realpath(__file__))
gringo = "gringo"
gringo305 = "gringo"
clasp = "clasp"
claspD = "claspD"
eclipse = "eclipse"
clingo = "clingo"
python = "python"

# encoding filenames
enc = dict(
    tkk = "3KK.lp ",
    adm = "admissible.lp ",
    base = "base.lp ",
    cf = "cf.lp ",
    cfi = "cfi.lp ",
    cmp = "complete.lp ",
    grd = "grounded.lp ",
    imax = "imax.lp ",
    model = "model.lp ",
    op = "op.lp ",
    opsm = "opsm.lp ",
    prf = "preferred.lp ",
    pref = "pref.lp ",
    prefpy = "pref.py ",
    prio_trans = "prio_trans.lp ",
    repr_change = "repr_change.lp",
    rmax = "rmax.lp ",
    show = "show.lp",
    stb = "stable.lp ",
    transformpl = "transform.pl ",
    transformpy = "transform.py ",
    formulatree = os.path.join('tools','formulatree.lp'))

# files to delete
filesToDelete=[]

def getoptval(config,section,option,default):
    if config.has_option(section,option):
        return config.get(section,option)
    else:
        return default

def initvars(cfgfile):
    global installdir, gringo, gringo305,clasp,claspD,eclipse,clingo,python
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
        clingo = getoptval(config,"Path","clingo",clingo)
        python = getoptval(config,"Path","python",python)
    else: #config file does not exist - create one
        config.add_section("Path")
        config.set("Path","installdir",installdir)
        config.set("Path","gringo", gringo)
        config.set("Path","gringo305", gringo)
        config.set("Path","clasp", clasp)
        config.set("Path","claspD", claspD)
        config.set("Path","eclipse", eclipse)
        config.set("Path","clingo", clingo)
        config.set("Path","python", python)
        config.write(open(cfgfile,'w'))

def main():
    parser= argparse.ArgumentParser(description='Program to compute different models and sets for a given ADF')
    parser.add_argument('instance', help='Filename of the ADF instance', default='instance.dl')
    parser.add_argument('-cf', '--conflict-free', help='compute the conflict-free interpretations', action='store_true', dest='conflict_free')
    parser.add_argument('-n', '--naive', help='compute the naive interpretations', action='store_true', dest='naive')
    parser.add_argument('-stg', '--stage', help='compute the stage interpretations', action='store_true', dest='stage')
    parser.add_argument('-se', '--semi-model', help='compute the semi-model interpretations', action='store_true', dest='semimodel')
    parser.add_argument('-m', '--model', help='compute the two-valued models', action='store_true', dest='model')
    parser.add_argument('-sm', '--stablemodel', help='compute the stable models', action='store_true', dest='smodel')
    parser.add_argument('-g', '--grounded', help='compute the grounded interpretation', action='store_true', dest='grounded')
    parser.add_argument('-c', '--complete', help='compute the complete interpretations', action='store_true', dest='complete')
    parser.add_argument('-a', '--admissible', help='compute the admissible interpretations', action='store_true', dest='admissible')
    parser.add_argument('-p', '--preferred', help='compute the preferred interpretations', action='store_true', dest='preferred')
    parser.add_argument('-t', '--transform', help='print the transformed adf to stdout', action='store_true', dest='print_transform')
    parser.add_argument('-dadm', '--transform_2_dsadf_adm', help='transforms a propositional formula adf into propositional formula dung style adf (admissible)', action='store_true',  dest='adf2dadf_adm')
    parser.add_argument('-cfg', help='specify a config-file', action='store', dest='cfgfile', default='~/.diamond')
    group = parser.add_mutually_exclusive_group()
    group.add_argument('-pf','--transform_pform', help='acceptance functions are given as propositional formulas (translation using ASP) (recommended)', action='store_true', dest='transformpform')
    group.add_argument('-pfe','--transform_pform_eclipse', help='acceptance functions are given as propositional formulas (translation using Eclipse Prolog)', action='store_true', dest='transformpformec')
    group.add_argument('-pfr','--transform_prio', help='transform a prioritized ADF before the computation', action='store_true', dest='transformprio')
    parser.add_argument('-all', '--all', help='compute interpretations for all semantics', action='store_true', dest='all')
    parser.add_argument('--version', help='prints the current version', action='store_true', dest='version')
    
    args=parser.parse_args()
    tmp=tempfile.NamedTemporaryFile(delete=True)
    instance=os.path.abspath(args.instance)
    initvars(args.cfgfile)
    claspstring = " 2> /dev/null | " + clasp + " 0 2> /dev/null"
    clingo_options = " 0 2> /dev/null"
    for el in iter(enc):
        enc[el] = os.path.join(installdir,encdir,enc[el])
    if args.version:
        print("==============================")
        print("DIAMOND version " + version)
        print("==============================")
    if args.adf2dadf_adm:
        print("==============================")
        print("transforming adf 2 dadf ...")
        with sp.Popen(clingo + " " + enc['formulatree'] + " " + instance + " 0 --outf=2", shell=True, stdout=sp.PIPE) as p:
            out =''
            for byteLine in p.stdout:
               out  = out + byteLine.decode(sys.stdout.encoding).strip()
            print(util.formtree2aspinput(adf2dadf_adm.transform(ft.formulatree(out))))
    if args.transformpform:
        tmp2=tempfile.NamedTemporaryFile(mode='w+t', encoding='utf-8', delete=False)
        instance = tmp2.name
        print("==============================")
        print("transforming pForm ADF using ASP...")
        sys.stdout.flush()
        with sp.Popen(gringo + " " + enc['repr_change'] + " " + os.path.abspath(args.instance) +  " |"+ clasp + " 0 ", shell=True,stdout=sp.PIPE,stderr=None) as p:
            sto = p.stdout
            i=1
            for byteLine in sto:
                line = byteLine.decode(sys.stdout.encoding).strip() 
                if "ci(" in line or "co(" in line:
                    tmp2.write(line.replace("constant", str(i)).replace(") l(","). l(").replace(") s(","). s(").replace(") co(","). co(").replace(") ci(","). ci(")+".\n")
                    i+=1
        tmp2.close()
        filesToDelete.append(instance)

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
    if args.conflict_free or args.all:
        print("==============================")
        print("conflict-free interpretations:")
        sys.stdout.flush()
        os.system(clingo + " " + enc['base'] + enc['op'] + enc['cfi'] + instance + " " + enc['show'] + clingo_options)
    if args.print_transform:
        os.system("cat " + instance)
    if args.model or args.all:
        print("==============================")
        print("two-valued models")
        sys.stdout.flush()
        os.system(clingo + " " + enc['base'] + enc['cf'] + enc['model'] + instance + " " + enc['show'] + clingo_options)
    if args.smodel or args.all:
        print("==============================")
        print("stable models:")
        sys.stdout.flush()
        os.system(clingo + " " + enc['base'] + enc['cf'] + enc['model'] + enc['opsm'] + enc['tkk'] + enc['stb'] + instance + " " + enc['show'] + clingo_options)
    if args.admissible or args.all:
        print("==============================")
        print("admissible interpretations:")
        sys.stdout.flush()
        os.system(clingo + " " + enc['base'] + enc['op'] + enc['adm'] + instance + " " + enc['show'] + clingo_options)
    if args.complete or args.all:
        print("==============================")
        print("complete interpretations:")
        sys.stdout.flush()
        os.system(clingo + " " + enc['base'] + enc['op'] + enc['cmp'] + instance + " " + enc['show'] + clingo_options)
    if args.grounded or args.all:
        print("==============================")
        print("grounded interpretation")
        sys.stdout.flush()
        os.system(clingo + " " + enc['base'] + enc['op'] + enc['tkk'] + enc['grd'] + instance + " " + enc['show'] + clingo_options)
    if args.preferred:
        print("==============================")
        print("preferred interpretations:")
        sys.stdout.flush()
        os.system(clingo + " " + enc['base'] + enc['op'] + enc['adm'] + instance + " " + enc['show'] + clingo_options + " --outf=2 | " + python + " " + enc['prefpy']  + " | " + clingo + " - " + enc['imax']  + enc['show'] + clingo_options)
    if args.naive:
        print("==============================")
        print("naive interpretations:")
        sys.stdout.flush()
        os.system(clingo + " " + enc['base'] + enc['op'] + enc['cfi'] + instance + " " + enc['show'] + clingo_options + " --outf=2 | " + python + " " + enc['prefpy']  + " | " + clingo + " - " + enc['imax']  + enc['show'] + clingo_options)
    if args.stage:
        print("==============================")
        print("stage interpretations:")
        sys.stdout.flush()
        os.system(clingo + " " + enc['base'] + enc['op'] + enc['cfi'] + instance + " " + enc['show'] + clingo_options + " --outf=2 | " + python + " " + enc['prefpy']  + " | " + clingo + " - " + enc['rmax']  + enc['show'] + clingo_options)
    if args.semimodel:
        print("==============================")
        print("semi-model interpretations:")
        sys.stdout.flush()
        os.system(clingo + " " + enc['base'] + enc['op'] + enc['adm'] + instance + " " + enc['show'] + clingo_options + " --outf=2 | " + python + " " + enc['prefpy']  + " | " + clingo + " - " + enc['rmax']  + enc['show'] + clingo_options)
    for fileToDelete in filesToDelete:
        os.remove(fileToDelete)
if __name__ == "__main__":
    main()
