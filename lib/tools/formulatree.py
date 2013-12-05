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
## formulatree.py
##

import sys
import os
import re
import subprocess as sp
sys.path.insert(0,os.path.dirname(os.path.abspath(__file__)))
import claspresult as claspresult

def formulatree(input):
    cr = claspresult.ClaspResult(input)
    if cr.sat:
        anss = cr.answersets[0]
        acs = [x[3:-1] for x in anss if x.startswith('ac(')]
        formOps = [x[7:-1] for x in anss if x.startswith('formOp(')]
        forms = [getformtriple(x[5:-1]) for x in anss if x.startswith('form(')]
        
        forest = {}
        for ac in acs:
            pos = getParenthesislessDelim(ac)[0]
            forest[ac[:pos]]=buildtree(ac[pos+1:],formOps,forms)
        return forest

def buildtree(formula, formOps, forms):
    if formula+',atom' in formOps:
        return formula
    children = getchildren((x for x in forms if x[0]==formula))
    if formula+',and' in formOps:
        return ['and',buildtree(children[0][2],formOps,forms),buildtree(children[1][2],formOps,forms)]
    if formula+',or' in formOps:
        return ['or',buildtree(children[0][2],formOps,forms),buildtree(children[1][2],formOps,forms)]
    if formula+',neg' in formOps:
        return ['neg',buildtree(children[0][2],formOps,forms)]
        
def getchildren(children):
    childlist=[]
    try:
        childlist.append(next(children))
        childlist.append(next(children))
        if childlist[0][1]=='r':
            childlist=childlist[::-1]
    except StopIteration:
        pass
    return childlist
        
def getParenthesislessDelim(string,delim=','):
    openpar = [m.start() for m in re.finditer('\(',string)]
    closepar = [m.start() for m in re.finditer('\)',string)]
    return [x for x in [m.start() for m in re.finditer(delim,string)] if sum (i < x for i in openpar) == sum(i < x for i in closepar)]

def getformtriple(form):
    commata = getParenthesislessDelim(form)
    return [form[:commata[0]],form[commata[0]+1:commata[1]],form[commata[1]+1:]]

def main():
    print(formulatree(sys.stdin))

if __name__ == "__main__":
    main()
