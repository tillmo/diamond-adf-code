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
%% fop.lp
%% Compute the ultimate operator directly on acceptance formulas.

% for each statement, guess a return value

1 { unsat(S, I) ; valid(S, I) ; conti(S, I) } 1 :- s(S), step(I).

% then disjunctively guess interpretations to coNP-prove the previously guessed values ok
% in each step, for each statement, we need an interpretation of all the statement's parents
% for unsat and valid, it suffices to guess one interpretation that can function as a counterexample (u/v)

t(u, P, S, I) | f(u, P, S, I) :- l(P, S), unsat(S, I).
t(v, P, S, I) | f(v, P, S, I) :- l(P, S), valid(S, I).

% for contingency, we just need two NP-witnesses, one for satisfiability (cs) and one for refutability (cr)

1 { t(cs, P, S, I) ; f(cs, P, S, I) } 1 :- l(P, S), conti(S, I).
1 { t(cr, P, S, I) ; f(cr, P, S, I) } 1 :- l(P, S), conti(S, I).

% it may not be that a formula is guessed contingent but there are no witnesses

:- conti(S, I), ac(S, F), not model(cs, S, I, F).
:- conti(S, I), ac(S, F), not notModel(cr, S, I, F).

% two-valued statements keep their truth value in the guesses
% (we only guess two-valued extensions of the input interpretation)

t(J, P, S, I) :- l(P, S), t(P, I), type(J).
f(J, P, S, I) :- l(P, S), f(P, I), type(J).

% saturate if ok, but only for stypes (saturation-types)

t(J, P, S, I) :- s(S), l(P, S), step(I), stype(J), ok.
f(J, P, S, I) :- s(S), l(P, S), step(I), stype(J), ok.

% the guessed interpretations are ok, if for no statement, there is a counterexample against the guessed unsat/valid combination

ok :- not ok.

ok :- ok(S) : s(S).

% a statement is ok if:
% (1) its acceptance formula was guessed valid, and the interpretation of its parents is not a counterexample for valid
ok(S) :- ac(S, F), valid(S, I), model(v, S, I, F).

% (2) its acceptance formula was guessed unsatisfiable, and the interpretation of its parents is not a counterexample for unsat
ok(S) :- ac(S, F), unsat(S, I), notModel(u, S, I, F).

% (3) the formula was guessed to be contingent (then by the constraints above there are witnesses for the formula being contingent)
ok(S) :- ac(S, F), conti(S, I).

% compute the model relation

type(T) :- stype(T).
stype(v).
stype(u).
type(cs).
type(cr).

model(J, S, I, c(v)) :- relevant(S, c(v)), step(I), type(J).
model(J, S, I, P) :- t(J, P, S, I).
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
notModel(J, S, I, P) :- f(J, P, S, I).
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

% compute links

l(P, S) :- relevant(S, P), s(P).

% figure out whether step(I) is a fixpoint

nofp(I) :- t(X,I), not valid(X,I), step(I).
nofp(I) :- valid(X,I), not t(X,I), step(I).
nofp(I) :- f(X,I), not unsat(X,I), step(I).
nofp(I) :- unsat(X,I), not f(X,I), step(I).
fp(I) :- not nofp(I), step(I).

