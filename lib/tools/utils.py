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
## utils.py
##

def formtree2aspinput(ft):
    statements = ''
    acs = ''
    for stmt in ft:
        statements += 'statement(' + stmt + ').\n'
        acs += 'ac(' + stmt + ',' + formula2ac(ft[stmt]) + ').\n'
    return statements + acs

def formula2ac(form):
    if type(form) == str:
        return form
    if len(form) == 2:
        return form[0] + '(' + formula2ac(form[1]) + ')'
    if len(form) == 3:
        return form[0] + '(' + formula2ac(form[1]) + ',' + formula2ac(form[2]) + ')'
