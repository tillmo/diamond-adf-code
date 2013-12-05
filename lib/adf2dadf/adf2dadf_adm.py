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
## adf2dadf_adm.py
##

import sys

"""
transforms a given adf (formulatree dict list) into a dung-style adf 
"""
def transform(adf):
    dadf = {}
    gen = newstmtgen(list(adf.keys()))
    for stmt in adf:
        dadf.update(transformstmt(stmt,adf[stmt],gen))
    return dadf

def transformstmt(stmt,ac,gen):
    dadf = {}
    if isdungstyle(ac):
        return {stmt:ac}
    else:
        newstmt=next(gen)
        if type(ac) == str:
            dadf.update({stmt:['neg',newstmt],newstmt:['neg',ac]})
        if len(ac) == 2:
            dadf.update({stmt:['neg',newstmt]})
            dadf.update(transformstmt(newstmt,ac[1],gen))
        if len(ac) == 3 and ac[0] == 'or':
            dadf.update({stmt:['neg',newstmt]})
            dadf.update(transformstmt(newstmt,['and',['neg',ac[1]],['neg',ac[2]]],gen))
        if len(ac) == 3 and ac[0] == 'and':
            newstmt2=next(gen)
            dadf.update({stmt:['and',['neg',newstmt],['neg',newstmt2]]})
            dadf.update(transformstmt(newstmt,['neg',ac[1]],gen))
            dadf.update(transformstmt(newstmt2,['neg',ac[2]],gen))
        return dadf

def newstmtgen(existing):
    i = 0
    while True:
        i += 1
        if not (str(i) in existing):
            yield str(i)
    
def isdungstyle(ft):
    if type(ft) == str:
        return False
    if len(ft) == 2 and type(ft[1])==str:
        return True
    if len(ft) == 3 and ft[0] == 'and':
        return (isdungstyle(ft[1]) and isdungstyle(ft[2]))
    return False
    
