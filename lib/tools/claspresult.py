#!/usr/bin/env python

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

def main():
    cr = ClaspResult(sys.stdin)
    print(cr.answersets)
    print(cr.getAS())
    print(cr.getASnbr())

if __name__ == "__main__":
    main()
