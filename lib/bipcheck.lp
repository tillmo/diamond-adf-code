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
subformula(X,F) :- ac(X,F),statement(X).
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
link(X,S) :- statement(S), atom(X), subformula(S,X), statement(X).

% guess 2 interpretations and compute those which have only a truth value flip with respect to its parent
{in(S,A,B,1)}:-statement(S), link(A,B), atom(S), subformula(B,S).
{in(S,A,B,3)}:-statement(S), link(A,B), atom(S), subformula(B,S).
:- in(S,S,B,1).
:- in(S,S,B,3).
out(S,A,B,1) :- not in(S,A,B,1), statement(S), link(A,B).
out(S,A,B,3) :- not in(S,A,B,3), statement(S), link(A,B).
in(S,A,B,2) :- in(S,A,B,1).
in(S,A,B,4) :- in(S,A,B,3).
out(S,A,B,2) :- out(S,A,B,1), S != A.
out(S,A,B,4) :- out(S,A,B,3), S != A.
in(S,S,B,2) :- out(S,S,B,1).
in(S,S,B,4) :- out(S,S,B,3).
interp(C) :- in(_,_,_,C).
interp(C) :- out(_,_,_,C).

% compute whether the interpretations are models or not
ismodel(X,A,B,C) :- atom(X), in(X,A,B,C).
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

nomodel(X,A,B,C) :- atom(X), out(X,A,B,C).
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

%bipolar counter-example
bip_ce(A,B) :- link(A,B), ac(B,F), ismodel(F,A,B,1), nomodel(F,A,B,2), nomodel(F,A,B,3), ismodel(F,A,B,4).
bip_ce2 :- bip_ce(A,B).
:- not bip_ce2.


#show bip_ce/2.
