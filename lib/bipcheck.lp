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
%% along with diamond. If not, see <http://www.gnu.org/licenses/>.
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% bipcheck.lp
%% check whether an ADF is bipolar

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

% for each link (P, S), guess two interpretations s1, a1 for all parents X of S

1 { t(s1, P, S, X) ; f(s1, P, S, X) } 1 :- l(P, S), l(X, S).
1 { t(a1, P, S, X) ; f(a1, P, S, X) } 1 :- l(P, S), l(X, S).

% force P false in s1 and a1
:- t(s1, P, S, P).
:- t(a1, P, S, P).
% force P true in s2 and a2
t(s2, P, S, P) :- l(P, S).
t(a2, P, S, P) :- l(P, S).

% all other parents get the same truth values in s1,s2 and a1,a2
t(s2, P, S, X) :- t(s1, P, S, X).
f(s2, P, S, X) :- f(s1, P, S, X), X != P.
t(a2, P, S, X) :- t(a1, P, S, X).
f(a2, P, S, X) :- f(a1, P, S, X), X != P.

% a link could possibly be attacking/supporting if there is a respective witness
possibly_attacking(P, S) :- ac(S, F), model(s1, P, S, F), notModel(s2, P, S, F).
possibly_supporting(P, S) :- ac(S, F), notModel(a1, P, S, F), model(a2, P, S, F).

% a link is dependent if it cannot possibly be supporting or attacking
dependent(P, S) :- l(P, S), not possibly_supporting(P, S), not possibly_attacking(P, S).

% the ADF is not bipolar if some link is dependent, and bipolar otherwise
not_bipolar :- dependent(P, S).

bipolar :- not not_bipolar.

:- not_bipolar.

% if the ADF is bipolar, say so
#show bipolar/0.

% define relevant interpretations for the model relation computation

type(s1).
type(s2).
type(a1).
type(a2).

% compute the model relation

model(J, P, S, c(v)) :- relevant(S, c(v)), l(P, S), type(J).
model(J, P, S, P) :- t(J, P, S, P).
model(J, P, S, neg(F)) :- relevant(S, neg(F)), notModel(J, P, S, F).
model(J, P, S, and(F,G)) :- relevant(S, and(F,G)), model(J, P, S, F), model(J, P, S, G).
model(J, P, S, or(F,G)) :- relevant(S, or(F,G)), model(J, P, S, F).
model(J, P, S, or(F,G)) :- relevant(S, or(F,G)), model(J, P, S, G).
model(J, P, S, imp(F,G)) :- relevant(S, imp(F,G)), model(J, P, S, G).
model(J, P, S, imp(F,G)) :- relevant(S, imp(F,G)), notModel(J, P, S, F).
model(J, P, S, iff(F,G)) :- relevant(S, iff(F,G)), model(J, P, S, F), model(J, P, S, G).
model(J, P, S, iff(F,G)) :- relevant(S, iff(F,G)), notModel(J, P, S, F), notModel(J, P, S, G).
model(J, P, S, xor(F,G)) :- relevant(S, xor(F,G)), model(J, P, S, F), notModel(J, P, S, G).
model(J, P, S, xor(F,G)) :- relevant(S, xor(F,G)), model(J, P, S, G), notModel(J, P, S, F).

notModel(J, P, S, c(f)) :- relevant(S, c(f)), l(P, S), type(J).
notModel(J, P, S, P) :- f(J, P, S, P).
notModel(J, P, S, neg(F)) :- relevant(S, neg(F)), model(J, P, S, F).
notModel(J, P, S, or(F,G)) :- relevant(S, or(F,G)), notModel(J, P, S, F), notModel(J, P, S, G).
notModel(J, P, S, and(F,G)) :- relevant(S, and(F,G)), notModel(J, P, S, F).
notModel(J, P, S, and(F,G)) :- relevant(S, and(F,G)), notModel(J, P, S, G).
notModel(J, P, S, imp(F,G)) :- relevant(S, imp(F,G)), model(J, P, S, F), notModel(J, P, S, G).
notModel(J, P, S, iff(F,G)) :- relevant(S, iff(F,G)), model(J, P, S, F), notModel(J, P, S, G).
notModel(J, P, S, iff(F,G)) :- relevant(S, iff(F,G)), notModel(J, P, S, F), model(J, P, S, G).
notModel(J, P, S, xor(F,G)) :- relevant(S, xor(F,G)), model(J, P, S, F), model(J, P, S, G).
notModel(J, P, S, xor(F,G)) :- relevant(S, xor(F,G)), notModel(J, P, S, G), notModel(J, P, S, F).

