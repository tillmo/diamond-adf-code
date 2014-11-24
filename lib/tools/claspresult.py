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
## claspresult.py
##

import sys
import json

class ClaspResult:
    """
    Represents the Result of the answer of a clasp-call
    Can be initialized with a json string or an input stream containing json input
    """  
    def __init__(self,jsoninst):
        if type(jsoninst)==str:
            claspresult=json.loads(jsoninst)
        else:
            claspresult=json.load(jsoninst)
        self.answersets=[]
        if claspresult['Result'] == "SATISFIABLE":
            self.sat=True
            for call in claspresult['Call']:
                for aset in call['Witnesses']:
                    self.answersets.append(aset['Value'])
        else:
            self.sat=False
            
    def getAS(self):
        for anss in self.answersets:
            res = ''
            for fact in anss:
                res = res + fact + ". "
            res = res + '\n'
        return res[:-1]
            
    def getASnbr(self):
        for i in range(0,len(self.answersets)):
            res = ''
            for fact in self.answersets[i]:
                res = res + fact[:-1] + "," + str(i) + "). "
            res = res + '\n'
        return res[:-1]

    def getEnumICCMAoutput(self):
        res = '['
        for anss in self.answersets:
            res = res + '['
            nofact = True
            for fact in anss:
                if fact[0] == 't':
                    res = res + fact[2:-1] + ','
                    nofact = False
            if not nofact:
                res = res[:-1]
            res = res + '],'
        return res[:-1] + ']'

    def getOneICCMAoutput(self,setnbr=0):
        res = '['
        nofact = True
        for fact in self.answersets[setnbr]:
            if fact[0] == 't':
                res = res + fact[2:-1] + ','
                nofact=False
        if nofact:
            return res + ']'
        else:
            return res[:-1] + ']'

def main():
    cr = ClaspResult(sys.stdin)
    print(cr.answersets)
    print(cr.getAS())
    print(cr.getASnbr())

if __name__ == "__main__":
    main()
