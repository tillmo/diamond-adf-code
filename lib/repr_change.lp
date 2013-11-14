%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Copyright 2013 Joerg Puehrer, puehrer@informatik.uni-leipzig.de
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
%% repr_change.lp
%%


%%% guess statement %%%
1{s(X):statement(X)}1.

%%% determine links %%%
subformula(S,F) :- ac(S,F),s(X).
subformula(S,F) :- subformula(S,neg(F)),s(X).
subformula(S,F) :- subformula(S,and(F,_)),s(X).
subformula(S,F) :- subformula(S,and(_,F)),s(X).
subformula(S,F) :- subformula(S,or(F,_)),s(X).
subformula(S,F) :- subformula(S,or(_,F)),s(X).
subformula(S,F) :- subformula(S,imp(_,F)),s(X).
subformula(S,F) :- subformula(S,imp(F,_)),s(X).
subformula(S,F) :- subformula(S,iff(_,F)),s(X).
subformula(S,F) :- subformula(S,iff(F,_)),s(X).
l(P,S) :- subformula(S,P),statement(P).


%%% guess interpretation %%%
1{interVal(P,c(v)),interVal(P,c(f))}1 :- l(P,S), s(S).
interpretationHasSomePositive :- interVal(P,c(v)).


%%%% evaluate formulas %%%
subformulaEval(iff(A,B),c(v)):-s(S), subformula(S,iff(A,B)),subformulaEval(A,c(v)),subformulaEval(B,c(v)).
subformulaEval(iff(A,B),c(v)):-s(S), subformula(S,iff(A,B)),subformulaEval(A,c(f)),subformulaEval(B,c(f)).
subformulaEval(iff(A,B),c(f)):-s(S), subformula(S,iff(A,B)),subformulaEval(A,c(v)),subformulaEval(B,c(f)).
subformulaEval(iff(A,B),c(f)):-s(S), subformula(S,iff(A,B)),subformulaEval(A,c(f)),subformulaEval(B,c(v)).

subformulaEval(imp(A,B),c(f)):-s(S), subformula(S,imp(A,B)),subformulaEval(A,c(t)),subformulaEval(B,c(f)).
subformulaEval(imp(A,B),c(v)):-s(S), subformula(S,imp(A,B)),subformulaEval(A,c(f)).
subformulaEval(imp(A,B),c(v)):-s(S), subformula(S,imp(A,B)),subformulaEval(B,c(v)).


subformulaEval(and(A,B),c(v)):-s(S), subformula(S,and(A,B)),subformulaEval(A,c(v)),subformulaEval(B,c(v)).
subformulaEval(and(A,B),c(f)):-s(S), subformula(S,and(A,B)),subformulaEval(A,c(f)).
subformulaEval(and(A,B),c(f)):-s(S), subformula(S,and(A,B)),subformulaEval(B,c(f)).

subformulaEval(or(A,B),c(f)):-s(S), subformula(S,or(A,B)),subformulaEval(A,c(f)),subformulaEval(B,c(f)).
subformulaEval(or(A,B),c(v)):-s(S), subformula(S,or(A,B)),subformulaEval(A,c(v)).
subformulaEval(or(A,B),c(v)):-s(S), subformula(S,or(A,B)),subformulaEval(B,c(v)).

subformulaEval(neg(A),c(f)):-s(S), subformula(S,neg(A)),subformulaEval(A,c(v)).
subformulaEval(neg(A),c(v)):-s(S), subformula(S,neg(A)),subformulaEval(A,c(f)).

subformulaEval(c(f),c(f)):-s(S), subformula(S,c(f)).
subformulaEval(c(v),c(v)):-s(S), subformula(S,c(v)).

subformulaEval(P,c(v)):-interVal(P,c(v)).
subformulaEval(P,c(f)):-interVal(P,c(f)).
%
%%%% generate ci/1, ci/3, co/1, co/3 predicates %%%
ci(S):- not interpretationHasSomePositive, subformulaEval(F,c(v)),ac(S,F).
co(S):- not interpretationHasSomePositive, subformulaEval(F,c(f)),ac(S,F).
%
ci(S,constant,P):- interVal(P,c(v)), subformulaEval(F,c(v)),ac(S,F).
co(S,constant,P):- interVal(P,c(v)), subformulaEval(F,c(f)),ac(S,F).
%
%
#hide.
#show ci/1.
#show ci/3.
#show co/1.
#show co/3.
#show l/2.
#show s/1.
