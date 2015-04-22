#!/usr/bin/env python
################################################################################
##
## Copyright 2013, 2014 Stefan Ellmauthaler, ellmauthaler@informatik.uni-leipzig.de
##                      Joerg Puehrer, puehrer@informatik.uni-leipzig.de
##                      Hannes Strass, strass@informatik.uni-leipzig.de
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
#import lib.adf2dadf.adf2dadf_adm as adf2dadf_adm
import lib.tools.utils as util
import lib.tools.claspresult as cr

version='2.0.1'

# default variables
encdir = "lib"
installdir = os.path.dirname(os.path.realpath(__file__))
eclipse = "eclipse"
clingo = "clingo"
python = "python"
transform = "asp"

# file extensions of instances that signify something
dung_af_file_extension = ".af"
bipolar_file_extension = ".badf"
formula_file_extension = ".adf"

verb_level = 1
args_cred = []
args_scep = []

# encoding filenames
enc = dict(
    tkk = "3KK.lp",
    adm = "admissible.lp",
    afop = "afop.lp",
    base = "base.lp",
    bipc = "bipcheck.lp",
    bop = "bop.lp",
    cf = "cf.lp",
    cfi = "cfi.lp",
    cmp = "complete.lp",
    fmodel = "fmodel.lp",
    formulatree = os.path.join('tools','formulatree.lp'),
    grd = "grounded.lp",    
    imax = "imax.lp",
    ltype = "linktypes.lp",
    model = "model.lp",
    naiD = "naiD.lp",
    op = "op.lp",
    opsm = "opsm.lp",
    prf = "preferred.lp",
    prfD = "prfD.lp",
    pref = "pref.lp",
    prefpy = "pref.py",
    prio_trans = "prio_trans.lp",
    repr_change = "repr_change.lp",
    rmax = "rmax.lp",
    semD = "semD.lp",
    show = "show.lp",
    show_iccma = "show_iccma.lp",
    stb = "stable.lp",
    stgD = "stgD.lp",
    tb2badf = "theorybase2badf.lp",
    transformpl = "transform.pl",
    transformpy = "transform.py",
    twovalued = "twovalued.lp")

# files to delete
filesToDelete=[]

def getoptval(config,section,option,default):
    if config.has_option(section,option):
        return config.get(section,option)
    else:
        return default

def initvars(cfgfile):
    global installdir, eclipse, clingo, python, transform
    cfgfile = os.path.expandvars(os.path.expanduser(cfgfile))
    config = cp.ConfigParser()
    if os.path.exists(cfgfile):
        config.read_file(open(cfgfile))
        installdir = getoptval(config,"Path","installdir",installdir)
        eclipse = getoptval(config,"Path","eclipse",eclipse)
        clingo = getoptval(config,"Path","clingo",clingo)
        python = getoptval(config,"Path","python",python)
        transform = getoptval(config,"Preferences","transform",transform)
    else: #config file does not exist - create one
        config.add_section("Path")
        config.set("Path","installdir",installdir)
        config.set("Path","eclipse", eclipse)
        config.set("Path","clingo", clingo)
        config.set("Path","python", python)
        config.add_section("Preferences")
        config.set("Preferences","transform", transform)
        config.write(open(cfgfile,'w'))

# simple dia_printing-function to only produce output appropriate to the chosen verbosity
def dia_print(text,verb=1):
    global verb_level
    if verb_level >= verb:
        print(text)

        
def onestepsolvercall(encodings,instance,headline,allmodels=True):
    global clingo_options,clstdout,clstderr,args_cred,args_scep,filesToDelete,iccma
    dia_print("==============================")
    dia_print(headline)
    decision=True
    if args_cred!=None:
        dia_print("Checking credulous acceptance of: "+args_cred[0],2)
        dia_print("Argument is credulously accepted iff answer is SATISFIABLE",2)
        if args_cred[0].startswith('"') and args_cred[0].endswith('"'):
            args_cred[0] = (args_cred[0])[1:-1]
        tmp_file_content=":- not t("+args_cred[0]+").\n"
        tmp_file = tempfile.NamedTemporaryFile(mode='w+t', encoding='utf-8', delete=False)
        tmp_file.write(tmp_file_content)
        tmp_file.flush()
        constraints=[tmp_file.name]
        filesToDelete.append(tmp_file.name)
        switchbool=False
    elif args_scep!=None:
        dia_print("Checking sceptical acceptance of: "+args_scep[0],2)
        dia_print("Argument is sceptically accepted iff answer is UNSATISFIABLE",2)
        if args_scep[0].startswith('"') and args_scep[0].endswith('"'):
            args_scep[0] = (args_scep[0])[1:-1]
        tmp_file_content=":- t("+args_scep[0]+").\n"
        tmp_file = tempfile.NamedTemporaryFile(mode='w+t', encoding='utf-8', delete=False)
        tmp_file.write(tmp_file_content)
        tmp_file.flush()
        constraints = [tmp_file.name]
        filesToDelete.append(tmp_file.name)
        switchbool=True
    elif (args_scep==None and args_cred==None):
        constraints = []
        decision = False
    sys.stdout.flush()
    if not allmodels and '0' in clingo_options:
        clingo_options.remove('0')
    #clingo_options= ['0']
    #clstderr=None
    #clstderr=sp.DEVNULL
    if iccma:
        with sp.Popen([clingo]+encodings+[enc['show']]+[instance]+constraints+clingo_options,stderr=clstderr,stdout=clstdout,shell=False) as p:
            outstring = p.communicate()[0].decode('UTF-8')
            res = cr.ClaspResult(outstring)
            if (not decision) and (not res.sat):
                dia_print('NO',0)
            elif decision:
                if res.sat!=switchbool: # a very bad hack to invert the answer of the ASP solver only in some cases (i.e. sceptical reasoning)
                    dia_print('YES',0)
                else:
                    dia_print('NO',0)
            else:
                if '0' in clingo_options:
                    dia_print(res.getEnumICCMAoutput(),0)
                else:
                    dia_print(res.getOneICCMAoutput(),0)
    else:
        with sp.Popen([clingo]+encodings+[enc['show']]+[instance]+constraints+clingo_options,stderr=clstderr,stdout=clstdout,shell=False) as p:
            None
    if not allmodels:
        clingo_options.append('0')

def twostepsolvercall(encodings1,encodings2,instance,headline):
    global clingo_options,clstderr
    dia_print("==============================")
    dia_print(headline)
    sys.stdout.flush()
    #clingo_options= ['0']
    #clstderr=sp.DEVNULL
    clingo1 = sp.Popen([clingo]+encodings1+[enc['show']]+[instance]+['--outf=2']+['0'], shell=False, stdout=sp.PIPE, stderr=clstderr)
    python2 = sp.Popen([python]+[enc['prefpy']],shell=False, stdin=clingo1.stdout, stdout=sp.PIPE)
    clingo1.stdout.close()
    clingo2 = sp.Popen([clingo]+encodings2+[enc['show']]+['-']+clingo_options, shell=False, stdin=python2.stdout, stderr=clstderr)
    python2.stdout.close()
    dia_print(clingo2.communicate()[0])    

def indicates_dung_af(instance):
    global dung_af_file_extension
    return instance.endswith(dung_af_file_extension)
    
def indicates_bipolarity(instance):
    global bipolar_file_extension
    return instance.endswith(bipolar_file_extension)

def indicates_formula_representation(instance):
    global formula_file_extension
    return instance.endswith(formula_file_extension)

def main():
    global clingo_options,clstdout,clstderr,verb_level,args_cred,args_scep,iccma
    parser= argparse.ArgumentParser(description='Program to compute different interpretations for a given ADF', prog='DIAMOND')
    parser.add_argument('instance', metavar='INSTANCE', help='Filename of the ADF instance', default='instance.dl')
    parser.add_argument('-cfi', '--conflict-free', help='compute the conflict-free interpretations', action='store_true', dest='conflict_free')
    parser.add_argument('-nai', '--naive', help='compute the naive interpretations', action='store_true', dest='naive')
    parser.add_argument('-naiD', '--naive-disjunctive', help='compute the naive interpretations (via a disjunctive encoding)', action='store_true', dest='naive_disjunctive')
    parser.add_argument('-stg', '--stage', help='compute the stage interpretations', action='store_true', dest='stage')
    parser.add_argument('-stgD', '--stage-disjunctive', help='compute the stage interpretations (via a disjunctive encoding)', action='store_true', dest='stage_disjunctive')
    parser.add_argument('-sem', '--semi-model', help='compute the semi-model interpretations', action='store_true', dest='semimodel')
    parser.add_argument('-semD', '--semi-model-disjunctive', help='compute the semi-model interpretations (via a disjunctive encoding)', action='store_true', dest='semimodel_disjunctive')
    parser.add_argument('-mod', '--model', help='compute the two-valued models', action='store_true', dest='model')
    parser.add_argument('-stm', '--stablemodel', help='compute the stable models', action='store_true', dest='smodel')
    parser.add_argument('-grd', '--grounded', help='compute the grounded interpretation', action='store_true', dest='grounded')
    parser.add_argument('-com', '--complete', help='compute the complete interpretations', action='store_true', dest='complete')
    parser.add_argument('-adm', '--admissible', help='compute the admissible interpretations', action='store_true', dest='admissible')
    parser.add_argument('-prf', '--preferred', help='compute the preferred interpretations', action='store_true', dest='preferred')
    parser.add_argument('-prfD', '--preferred-disjunctive', help='compute the preferred interpretations (via a disjunctive encoding)', action='store_true', dest='preferred_disjunctive')
    parser.add_argument('-enum', '--enum', help='enumerate all models', action='store_true', dest='enumeration')
    parser.add_argument('-all', '--all', help='compute interpretations for all semantics', action='store_true', dest='all')
    parser.add_argument('-t', '--transform', help='print the transformed adf to stdout', action='store_true', dest='print_transform')
    parser.add_argument('-bc', '--bipolarity-check', help='Check whether a given instance is bipolar or not (implies -pf)',action='store_true',dest='bipolarity_check')
    parser.add_argument('-clt', '--compute-link-types', help='compute the link types (implies instance is bipolar)', action='store_true', dest='compute_link_type')
    #parser.add_argument('-dadm', '--transform_2_dsadf_adm', help='transforms a propositional formula adf into propositional formula dung style adf (admissible)', action='store_true',  dest='adf2dadf_adm')
    reasoning_mode = parser.add_mutually_exclusive_group()
    reasoning_mode.add_argument('-cred', metavar='ARGUMENT', help='Check credulous acceptance of ARGUMENT', nargs=1, type=str)
    reasoning_mode.add_argument('-scep', metavar='ARGUMENT', help='Check sceptical acceptance of ARGUMENT', nargs=1, type=str)
    group = parser.add_mutually_exclusive_group()
    group.add_argument('-af','--argumentation-framework', help='input is a Dung argumentation framework in ASPARTIX syntax with arg/1 and att/2', action='store_true', dest='af_input')
    group.add_argument('-b','--bipolar', help='acceptance functions are given as propositional formulas, attacking and supporting links are specified (implies -pf)', action='store_true', dest='bipolar_input')
    group.add_argument('-pf','--propositional-formulas', help='acceptance functions are given as propositional formulas', action='store_true', dest='transformpform')
    #group.add_argument('-pf','--propositional-formulas-eclipse', help='acceptance functions are given as propositional formulas (translation using ECLiPSe Prolog)', action='store_true', dest='transformpformec')
    group.add_argument('-fr','--functional-representation', help='acceptance functions are given in extensional form', action='store_true', dest='extensionalform')
    group.add_argument('-pr','--priorities', help='acceptance functions are given as preferences among statements', action='store_true', dest='transformprio')
    group.add_argument('-tb','--theory-base', help='input is a theory base consisting of strict and defeasible rules (implies -b)', action='store_true', dest='theory_base_input')
    parser.add_argument('-c', help='specify a config-file', action='store', dest='cfgfile', default='~/.diamond')
    parser.add_argument('--version', help='prints the current version', action='version', version='%(prog)s '+ version)
    parser.add_argument('-v','--verbose', choices=['0','1','2','json','debug','iccma'], dest='verbosity', default='1', help='Control the verbosity of DIAMOND')
    args=parser.parse_args()
    args_cred=args.cred
    args_scep=args.scep
    tmp=tempfile.NamedTemporaryFile(delete=True)
    instance=os.path.abspath(args.instance)
    initvars(args.cfgfile)
    for el in iter(enc):
        enc[el] = os.path.join(installdir,encdir,enc[el])
    # compute some handy Booleans which are needed later
    af = (indicates_dung_af(args.instance) or args.af_input)
    bipolar = (indicates_bipolarity(args.instance) or args.bipolar_input)
    model_only = args.model and not args.conflict_free and not args.naive and not args.stage and not args.semimodel and not args.naive_disjunctive and not args.stage_disjunctive and not args.semimodel_disjunctive and not args.smodel and not args.grounded and not args.complete and not args.admissible and not args.preferred and not args.preferred_disjunctive and not args.all and not args.print_transform
    do_transformation = args.conflict_free or args.naive or args.stage or args.semimodel or args.naive_disjunctive or args.stage_disjunctive or args.semimodel_disjunctive or args.smodel or args.grounded or args.complete or args.admissible or args.preferred or args.preferred_disjunctive or args.all or args.print_transform
    transform_to_functions = ((indicates_formula_representation(args.instance) or args.transformpform) and not bipolar)
    # assign the correct encodings of the semantics
    model_encoding=[enc['base'],enc['cf'],enc['model']]
    operators=[enc['base'],enc['op']]
    # check if we get theory base input and add the translation to encodings
    if args.theory_base_input:
        model_encoding=[enc['fmodel'],enc['tb2badf']]
        operators=[enc['bop'],enc['tb2badf']]
    # check if we are dealing with an af and choose the respective operator if so
    if af:
        model_encoding=[enc['afop'],enc['cmp'],enc['twovalued']]
        operators=[enc['afop']]
    # check if the model semantics is the only thing we should compute for a formula ADF and use a special encoding
    if model_only and (indicates_formula_representation(args.instance) or bipolar):
        model_encoding=[enc['fmodel']]
    # otherwise, the choice of operator depends on bipolarity of the instance
    if bipolar:
        operators=[enc['bop']]
    # if the information is insufficient, complain terribly
    if ((not bipolar) and (not transform_to_functions) and (not af) and (not args.theory_base_input)):
        dia_print("No input format specified or indicated! Assuming extensional representation of acceptance functions.")
    # set clingo options
    clingo_options = ['0']
    if not args.enumeration:
        clingo_options.remove('0')
    clstderr = sp.DEVNULL
    clstdout = None
    iccma = False
    if args.verbosity == '0':
        clingo_options.append('--verbose=0')
        verb_level = 0
    elif args.verbosity == '1':
        clingo_options.append('--stats=0')
        verb_level = 1
    elif args.verbosity == '2':
        clingo_options.append('--verbose=2')
        verb_level = 2
    elif args.verbosity == 'json':
        clingo_options.append('--outf=2')
        verb_level = 0
    elif args.verbosity == 'debug':
        clstderr = None
        verb_level = 2
    elif args.verbosity == 'iccma':
        verb_level = 0
        iccma = True
        clstdout = sp.PIPE
        clingo_options.append('--outf=2')
        clingo_options.append('--project')
#    if args.adf2dadf_adm:
#        dia_print("==============================")
#        dia_print("transforming adf 2 dadf ...")
#        with sp.Popen(clingo + " " + enc['formulatree'] + " " + instance + " 0 --outf=2", shell=True, stdout=sp.PIPE) as p:
#            out =''
#            for byteLine in p.stdout:
#               out  = out + byteLine.decode(sys.stdout.encoding).strip()
#            dia_print(util.formtree2aspinput(adf2dadf_adm.transform(ft.formulatree(out))))
    if args.bipolarity_check:
        onestepsolvercall([enc['bipc']],instance,"bipolarity check:",False)
    if args.compute_link_type:
        dia_print("==============================")
        dia_print("compute link-types:")
        clingo_options.append('--enum-mode=brave')
        sys.stdout.flush()
        with sp.Popen([clingo,enc['ltype'],instance]+clingo_options,stderr=clstderr,shell=False) as p:
            None
        clingo_options.remove('--enum-mode=brave')
    if (transform_to_functions and do_transformation and transform=="asp"):
        tmp2=tempfile.NamedTemporaryFile(mode='w+t', encoding='utf-8', delete=False)
        instance = tmp2.name
        dia_print("==============================")
        dia_print("transforming pForm ADF using ASP...")
        sys.stdout.flush()
        with sp.Popen([clingo]+[enc['repr_change']]+[os.path.abspath(args.instance)]+['0'], shell=False,stdout=sp.PIPE,stderr=None) as p:
            sto = p.stdout
            i=1
            for byteLine in sto:
                line = byteLine.decode(sys.stdout.encoding).strip() 
                if "ci(" in line or "co(" in line:
                    tmp2.write(line.replace("constant", str(i)).replace(") l(","). l(").replace(") s(","). s(").replace(") co(","). co(").replace(") ci(","). ci(")+".\n")
                    i+=1
        tmp2.close()
        filesToDelete.append(instance)
    if (transform_to_functions and do_transformation and transform=="eclipse"):
        tmp2=tempfile.NamedTemporaryFile(delete=False)
        instance = tmp2.name
        filesToDelete.append(instance)
        dia_print("==============================")
        dia_print("transforming pForm ADF using Eclipse...")
        sys.stdout.flush()
        start = time.time()
        with sp.Popen([eclipse,"-f",enc['transformpl'],"-e", "main", "--", os.path.abspath(args.instance),instance],stderr=None,shell=False) as p:
            None
        elapsed = (time.time() - start)
        elapsedstring = "%.3f" % (elapsed,)
        dia_print("transformation took " + elapsedstring  + " seconds")    
    if args.transformprio and do_transformation:
        tmp2 = tempfile.NamedTemporaryFile(delete=False)
        instance = tmp2.name
        dia_print("==============================")
        dia_print("transforming prioritized ADF...")
        sys.stdout.flush()
        start = time.time()
        wd = os.getcwd()
        os.chdir(installdir + "/" + encdir)
        os.system("python " + enc['transformpy'] + os.path.abspath(args.instance) + " > " + instance)
        os.chdir(wd)
        elapsed = (time.time() - start)
        elapsedstring = "%.3f" % (elapsed,)
        dia_print("transformation took " + elapsedstring  + " seconds")    
        filesToDelete.append(instance)
    if args.print_transform:
        os.system("cat " + instance)
    if args.model or args.all:
        onestepsolvercall(model_encoding,instance,"two-valued models")
    if args.smodel or args.all: # note that stable models are not yet working for the functional representation
        onestepsolvercall([enc['base'],enc['cf'],enc['model'],enc['opsm'],enc['tkk'],enc['stb']],instance,"stable models:")
    if args.conflict_free or args.all:
        onestepsolvercall(operators+[enc['cfi']],instance,"conflict-free interpretations:")
    if args.admissible or args.all:
        onestepsolvercall(operators+[enc['adm']],instance,"admissible interpretations:")
    if args.complete or args.all:
        onestepsolvercall(operators+[enc['cmp']],instance,"complete interpretations:")
    if args.grounded or args.all:
        onestepsolvercall(operators+[enc['tkk'],enc['grd']],instance,"grounded interpretation:")
    if args.naive_disjunctive or args.all:
        onestepsolvercall(operators+[enc['naiD']],instance,"naive interpretations:")
    if args.preferred_disjunctive or args.all:
        onestepsolvercall(operators+[enc['prfD']],instance,"preferred interpretations:")
    if args.stage_disjunctive or args.all:
        onestepsolvercall(operators+[enc['stgD']],instance,"stage interpretations:")
    if args.semimodel_disjunctive or args.all:
        onestepsolvercall(operators+[enc['semD']],instance,"semi-model interpretations:")
    if args.preferred or args.all:
        twostepsolvercall(operators+[enc['cmp']],[enc['imax']],instance,"preferred interpretations:")
    if args.naive or args.all:
        twostepsolvercall(operators+[enc['cfi']],[enc['imax']],instance,"naive interpretations:")
    if args.stage or args.all:
        twostepsolvercall(operators+[enc['cfi']],[enc['rmax']],instance,"stage interpretations:")
    if args.semimodel or args.all:
        twostepsolvercall(operators+[enc['cmp']],[enc['rmax']],instance,"semi-model interpretations:")
    for fileToDelete in filesToDelete:
        os.remove(fileToDelete)
if __name__ == "__main__":
    main()
