#!/usr/bin/env python
################################################################################
##
## Copyright 2013 Stefan Ellmauthaler, ellmauthaler@informatik.uni-leipzig.de
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
## pref.py
##

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
