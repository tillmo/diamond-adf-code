%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Copyright 2013 Stefan Ellmauthaler, ellmauthaler@informatik.uni-leipzig.de
%%                Joerg Puehrer, puehrer@informatik.uni-leipzig.de
%%
%% This file is part of diamond.
%%
%% diamond is free software: you can redistribute it and/or modify
%% it under the terms of the GNU General Public License as published by
%% the Free Software Foundation, either version 3 of the License, or
%% (at your option) any later version.
%%
%% diamond is distributed in the hope that it will be useful,
%% but WITHOUT ANY WARRANTY; without even the implied warranty of
%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%% GNU General Public License for more details.
%%
%% You should have received a copy of the GNU General Public License
%% along with diamond.  If not, see <http://www.gnu.org/licenses/>.
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

subformula(F) :- ac(S,F).
subformula(F) :- subformula(and(F,_)).
subformula(F) :- subformula(and(_,F)).
subformula(F) :- subformula(or(F,_)).
subformula(F) :- subformula(or(_,F)).
subformula(F) :- subformula(neg(F)).

formOp(F,atom) :- subformula(F), ac(F,_).
formOp(and(F1,F2),and) :- subformula(and(F1,F2)).
formOp(or(F1,F2),or) :- subformula(or(F1,F2)).
formOp(neg(F1),neg) :- subformula(neg(F1)).

form(and(F1,F2),l,F1) :- subformula(and(F1,F2)).
form(and(F1,F2),r,F2) :- subformula(and(F1,F2)).
form(or(F1,F2),l,F1) :- subformula(or(F1,F2)).
form(or(F1,F2),r,F2) :- subformula(or(F1,F2)).
form(neg(F1),c,F1) :- subformula(neg(F1)).

#show ac/2.
#show formOp/2.
#show form/3.
