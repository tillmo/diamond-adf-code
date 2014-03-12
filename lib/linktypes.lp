%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Copyright 2013 Stefan Ellmauthaler, ellmauthaler@informatik.uni-leipzig.de
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
%%
%% bipcheck.lp
%%% ---------------------------
% splitting a formula into its subformulas
subformula(X,F) :- ac(X,F),s(X).
subformula(X,F) :- subformula(X,and(F,_)).
subformula(X,F) :- subformula(X,and(_,F)).
subformula(X,F) :- subformula(X,or(_,F)).
subformula(X,F) :- subformula(X,or(F,_)).
subformula(X,F) :- subformula(X,neg(F)).
subformula(X,F) :- subformula(X,xor(F,_)).
subformula(X,F) :- subformula(X,xor(_,F)).
subformula(X,F) :- subformula(X,imp(F,_)).
subformula(X,F) :- subformula(X,imp(_,F)).
subformula(X,F) :- subformula(X,iff(F,_)).
subformula(X,F) :- subformula(X,iff(_,F)).
subformula(F) :- subformula(_,F).

% decide whether a subformula is an atom or not
noatom(F) :- subformula(F;F1;F2), F=and(F1,F2).
noatom(F) :- subformula(F;F1;F2), F=or(F1,F2).
noatom(F) :- subformula(F;F1), F=neg(F1).
noatom(F) :- subformula(F;F1;F2), F=xor(F1,F2).
noatom(F) :- subformula(F;F1;F2), F=imp(F1,F2).
noatom(F) :- subformula(F;F1;F2), F=iff(F1,F2).

atom(X) :- subformula(X), not noatom(X).
atom(X) :- subformula(X), X=c(v).
atom(X) :- subformula(X), X=c(f).

% get the links between statements
link(X,S) :- s(S), atom(X), subformula(S,X), s(X).

% select one link and guess whether it is supporting or attacking
1{sellink(A,B):link(A,B)}1.
att(A,B) :- sellink(A,B), not sup(A,B).
sup(A,B) :- sellink(A,B), not att(A,B).

% use saturation to check whether the guess was right or not
t(S,A,B,1) | f(S,A,B,1) :- sellink(A,B), s(S), atom(S), subformula(B,S).
:- t(S,S,B,1).
t(S,A,B,2) :- t(S,A,B,1).
f(S,A,B,2) :- f(S,A,B,1), S != A.
t(S,S,B,2) :- f(S,S,B,1).

noattclash(A,B) :- sellink(A,B), ac(B,F), ismodel(F,A,B,1).
noattclash(A,B) :- sellink(A,B), ac(B,F), nomodel(F,A,B,1), nomodel(F,A,B,2).
nosupclash(A,B) :- sellink(A,B), ac(B,F), nomodel(F,A,B,1).
nosupclash(A,B) :- sellink(A,B), ac(B,F), ismodel(F,A,B,1), ismodel(F,A,B,2).

ok(A,B) :- noattclash(A,B), att(A,B).
ok(A,B) :- nosupclash(A,B), sup(A,B).

:- not ok(A,B), sellink(A,B).

t(S,A,B,1) :- ok(A,B), f(S,A,B,1), S != A.
f(S,A,B,1) :- ok(A,B), t(S,A,B,1), S != A.

% compute whether the interpretations are models or not
ismodel(X,A,B,C) :- atom(X), t(X,A,B,C).
ismodel(c(v),A,B,C) :- atom(c(v)), link(A,B), interp(C).
ismodel(neg(F),A,B,C) :- subformula(neg(F)), nomodel(F,A,B,C).
ismodel(and(F1,F2),A,B,C) :- subformula(and(F1,F2)), ismodel((F1;F2),A,B,C).
ismodel(or(F1,F2),A,B,C) :- subformula(or(F1,F2)), ismodel(F1,A,B,C).
ismodel(or(F1,F2),A,B,C) :- subformula(or(F1,F2)), ismodel(F2,A,B,C).
ismodel(xor(F1,F2),A,B,C) :- subformula(xor(F1,F2)), ismodel(F1,A,B,C), nomodel(F2,A,B,C).
ismodel(xor(F1,F2),A,B,C) :- subformula(xor(F1,F2)), ismodel(F2,A,B,C), nomodel(F1,A,B,C).
ismodel(imp(F1,F2),A,B,C) :- subformula(imp(F1,F2)), nomodel(F1,A,B,C).
ismodel(imp(F1,F2),A,B,C) :- subformula(imp(F1,F2)), ismodel((F1;F2),A,B,C).
ismodel(iff(F1,F2),A,B,C) :- subformula(iff(F1,F2)), ismodel((F1;F2),A,B,C).
ismodel(iff(F1,F2),A,B,C) :- subformula(iff(F1,F2)), nomodel((F1;F2),A,B,C).

nomodel(X,A,B,C) :- atom(X), f(X,A,B,C).
nomodel(c(f),A,B,C) :- atom(c(f)), link(A,B), interp(C).
nomodel(neg(F),A,B,C) :- subformula(neg(F)), ismodel(F,A,B,C).
nomodel(and(F1,F2),A,B,C) :- subformula(and(F1,F2)), nomodel(F1,A,B,C).
nomodel(and(F1,F2),A,B,C) :- subformula(and(F1,F2)), nomodel(F2,A,B,C).
nomodel(or(F1,F2),A,B,C) :- subformula(or(F1,F2)), nomodel(F1,A,B,C), nomodel(F2,A,B,C).
nomodel(xor(F1,F2),A,B,C) :- subformula((F1,F2)), ismodel(F1,A,B,C), ismodel(F2,A,B,C).
nomodel(xor(F1,F2),A,B,C) :- subformula(xor(F1,F2)), nomodel(F1,A,B,C), nomodel(F2,A,B,C).
nomodel(imp(F1,F2),A,B,C) :- subformula(imp(F1,F2)), ismodel(F1,A,B,C), nomodel(F2,A,B,C).
nomodel(iff(F1,F2),A,B,C) :- subformula(iff(F1,F2)), nomodel(F1,A,B,C), ismodel(F2,A,B,C).
nomodel(iff(F1,F2),A,B,C) :- subformula(iff(F1,F2)), nomodel(F2,A,B,C), ismodel(F1,A,B,C).

interp(C) :- t(_,_,_,C).
interp(C) :- f(_,_,_,C).

#show att/2.
#show sup/2.
