%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Copyright 2014 Hannes Strass, strass@informatik.uni-leipzig.de
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
%% biop.lp
%%
%% Definition of the ultimate characteristic operator for bipolar ADFs
%% operates directly on acceptance conditions
%% requires definition of:
%% s/1, ac/2, sup/2, att/2 (input ADF), and
%%
%% input:
%% * a step/1
%% * a three-valued interpretation, declared via t/2, f/2, u/2
%%
%% output:
%% * a three-valued interpretation represented via valid/2, unsat/2, conti/2
%% * ref/2 and sat/2
%%

% get the undecided parents P of each statement S

l(A, B) :- sup(A, B).
l(A, B) :- att(A, B).

up(P, S, I) :- l(P, S), step(I), u(P, I).

psup(P, S, I) :- sup(P, S), up(P, S, I).
patt(P, S, I) :- att(P, S), up(P, S, I).

% to figure out whether the acceptance condition is a tautology, 
% set supporters to false and attackers to true
% if the resulting interpretation makes S true, then S is valid

model(refute, S, I, P) :- patt(P, S, I).
notModel(refute, S, I, P) :- psup(P, S, I).

valid(S, I) :- ac(S, F), model(refute, S, I, F).

% otherwise, it is refutable
ref(S, I) :- ac(S, F), notModel(refute, S, I, F).

% to figure out whether the acceptance condition is unsatisfiable,
% set supporters to true and attackers to false
% if the resulting interpretation makes S false, then S is unsat

model(satisfy, S, I, P) :- psup(P, S, I).
notModel(satisfy, S, I, P) :- patt(P, S, I).

unsat(S, I) :- ac(S, F), notModel(satisfy, S, I, F).

% otherwise, it is satisfiable
sat(S, I) :- ac(S, F), model(satisfy, S, I, F).

% the acceptance condition is contingent iff it is both refutable and satisfiable
conti(S, I) :- sat(S, I), ref(S, I).

% figure out whether various interpretations are models for acceptance formulas
% model(J, S, I, F) means that the two-valued interpretation at step I 
% where S is considered true if t(S, I) holds and false otherwise
% is a model for formula F, where J is a type among {valid, unsat}

type(refute).
type(satisfy).

model(J, S, I, c(v)) :- relevant(S, c(v)), step(I), type(J).
model(J, S, I, P) :- l(P, S), t(P, I), type(J).
model(J, S, I, neg(F)) :- relevant(S, neg(F)), notModel(J, S, I, F).
model(J, S, I, and(F,G)) :- relevant(S, and(F,G)), model(J, S, I, F), model(J, S, I, G).
model(J, S, I, or(F,G)) :- relevant(S, or(F,G)), model(J, S, I, F).
model(J, S, I, or(F,G)) :- relevant(S, or(F,G)), model(J, S, I, G).
model(J, S, I, imp(F,G)) :- relevant(S, imp(F,G)), model(J, S, I, G).
model(J, S, I, imp(F,G)) :- relevant(S, imp(F,G)), notModel(J, S, I, F).
model(J, S, I, iff(F,G)) :- relevant(S, iff(F,G)), model(J, S, I, F), model(J, S, I, G).
model(J, S, I, iff(F,G)) :- relevant(S, iff(F,G)), notModel(J, S, I, F), notModel(J, S, I, G).
model(J, S, I, xor(F,G)) :- relevant(S, xor(F,G)), model(J, S, I, F), notModel(J, S, I, G).
model(J, S, I, xor(F,G)) :- relevant(S, xor(F,G)), model(J, S, I, G), notModel(J, S, I, F).

notModel(J, S, I, c(f)) :- relevant(S, c(f)), step(I), type(J).
notModel(J, S, I, P) :- l(P, S), f(P, I), type(J).
notModel(J, S, I, neg(F)) :- relevant(S, neg(F)), model(J, S, I, F).
notModel(J, S, I, or(F,G)) :- relevant(S, or(F,G)), notModel(J, S, I, F), notModel(J, S, I, G).
notModel(J, S, I, and(F,G)) :- relevant(S, and(F,G)), notModel(J, S, I, F).
notModel(J, S, I, and(F,G)) :- relevant(S, and(F,G)), notModel(J, S, I, G).
notModel(J, S, I, imp(F,G)) :- relevant(S, imp(F,G)), model(J, S, I, F), notModel(J, S, I, G).
notModel(J, S, I, iff(F,G)) :- relevant(S, iff(F,G)), model(J, S, I, F), notModel(J, S, I, G).
notModel(J, S, I, iff(F,G)) :- relevant(S, iff(F,G)), notModel(J, S, I, F), model(J, S, I, G).
notModel(J, S, I, xor(F,G)) :- relevant(S, xor(F,G)), model(J, S, I, F), model(J, S, I, G).
notModel(J, S, I, xor(F,G)) :- relevant(S, xor(F,G)), notModel(J, S, I, G), notModel(J, S, I, F).

% figure out what formulas are relevant for statement S:
% obviously, its acceptance formula F and all of F's subformulas

relevant(S, F) :- ac(S, F).

relevant(S, F) :- relevant(S, neg(F)).
relevant(S, F) :- relevant(S, and(F,_)).
relevant(S, F) :- relevant(S, and(_,F)).
relevant(S, F) :- relevant(S, or(F,_)).
relevant(S, F) :- relevant(S, or(_,F)).
relevant(S, F) :- relevant(S, imp(F,_)).
relevant(S, F) :- relevant(S, imp(_,F)).
relevant(S, F) :- relevant(S, iff(F,_)).
relevant(S, F) :- relevant(S, iff(_,F)).
relevant(S, F) :- relevant(S, xor(F,_)).
relevant(S, F) :- relevant(S, xor(_,F)).

