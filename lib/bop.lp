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
%% bop.lp
%%
% ---------------------------
% Definition of the ultimate characteristic operator for bipolar ADFs
% operates directly on acceptance conditions
% requires definition of statement/1 or s/1, ac/2, sup/2, att/2
%
% usage:
% define predicate step(I), where I is an integer
% define in(S,I) for each S which is already labeled as t
% define out(S,I) for each S which is already labeled as f
% valid(S,I) represents all S which are labeled t by the operator
% unsat(S,I) represents all S which are labeled f by the operator
% if the input is a fixpoint for the operator, fp(I) is set, nofp(I) otherwise.
% ---------------------------

s(S) :- statement(S).

% get the undecided parents P of each statement S

l(A, B) :- sup(A, B).
l(A, B) :- att(A, B).

up(P, S, I) :- l(P, S), step(I), not in(P, I), not out(P, I).

psup(P, S, I) :- sup(P, S), up(P, S, I).
patt(P, S, I) :- att(P, S), up(P, S, I).

% to figure out whether the acceptance condition is a tautology, 
% set supporters to false and attackers to true
% if the resulting interpretation makes S true, then S is valid

model(valid, S, I, P) :- patt(P, S, I).

valid(S,I) :- ac(S, F), model(valid, S, I, F).

% to figure out whether the acceptance condition is unsatisfiable,
% set supporters to true and attackers to false
% if the resulting interpretation makes S false, then S is unsat

model(unsat, S, I, P) :- psup(P, S, I).

unsat(S,I) :- ac(S, F), s(S), step(I), not model(unsat, S, I, F).

% figure out whether various interpretations are models for acceptance formulas
% model(J, S, I, F) means that the two-valued interpretation at step I 
% where S is considered true if in(S, I) holds and false otherwise
% is a model for formula F, where J is a type among {valid, unsat}

type(valid).
type(unsat).

model(J, S, I, c(v)) :- relevant(S, c(v)), step(I), type(J).
model(J, S, I, P) :- l(P, S), in(P, I), type(J).
model(J, S, I, neg(F)) :- relevant(S, neg(F)), step(I), type(J), not model(J, S, I, F).
model(J, S, I, and(F,G)) :- relevant(S, and(F,G)), model(J, S, I, F), model(J, S, I, G).
model(J, S, I, or(F,G)) :- relevant(S, or(F,G)), model(J, S, I, F).
model(J, S, I, or(F,G)) :- relevant(S, or(F,G)), model(J, S, I, G).
model(J, S, I, imp(F,G)) :- relevant(S, imp(F,G)), model(J, S, I, G).
model(J, S, I, imp(F,G)) :- relevant(S, imp(F,G)), step(I), type(J), not model(J, S, I, F).
model(J, S, I, iff(F,G)) :- relevant(S, iff(F,G)), model(J, S, I, F), model(J, S, I, G).
model(J, S, I, iff(F,G)) :- relevant(S, iff(F,G)), step(I), type(J), not model(J, S, I, F), not model(J, S, I, G).
model(J, S, I, xor(F,G)) :- relevant(S, xor(F,G)), step(I), type(J), model(J, S, I, F), not model(J, S, I, G).
model(J, S, I, xor(F,G)) :- relevant(S, xor(F,G)), step(I), type(J), model(J, S, I, G), not model(J, S, I, F).

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

% figure out whether step(I) is a fixpoint

nofp(I) :- in(X,I), not valid(X,I), step(I).
nofp(I) :- valid(X,I), not in(X,I), step(I).
nofp(I) :- out(X,I), not unsat(X,I), step(I).
nofp(I) :- unsat(X,I), not out(X,I), step(I).
fp(I) :- not nofp(I), step(I).
