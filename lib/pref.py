#!/usr/bin/env python

import sys
import json

def main():
    linenr = 0
    aset = 0
    lines = ''
    done = False
    for line in sys.stdin:
        lines = lines + line
    claspresult = json.loads(lines)
    if claspresult['Result'] == "SATISFIABLE":
        for answerset in claspresult['Witnesses']:
            aset += 1
            result = ''
            for fact in answerset['Value']:
                result = result + fact[:-1] + "," + str(aset) + "). "
            print(result)

if __name__ == "__main__":
    main()
