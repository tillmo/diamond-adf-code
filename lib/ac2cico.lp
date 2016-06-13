%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Copyright 2016 Hannes Strass, strass@informatik.uni-leipzig.de
%%           2015 Matti Berthold (provided a similar for GRAPPA input)
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
%% ac2cico.lp
%%
%% Transform ADFs in acceptance formula syntax into functional syntax
%%
%% Input: an ADF specified using s/1 and ac/2.
%%
%% Output: an ADF specified using s/1, l/2, and ci/1, ci/3, co/1, co/3.
%%

%% determine subformulas

subformula(S, F) :- ac(S, F).

subformula(S, F) :- subformula(S, neg(F)).
subformula(S, F) :- subformula(S, and(F,_)).
subformula(S, F) :- subformula(S, and(_,F)).
subformula(S, F) :- subformula(S, or(F,_)).
subformula(S, F) :- subformula(S, or(_,F)).
subformula(S, F) :- subformula(S, imp(_,F)).
subformula(S, F) :- subformula(S, imp(F,_)).
subformula(S, F) :- subformula(S, iff(_,F)).
subformula(S, F) :- subformula(S, iff(F,_)).

%% determine links

l(P, S) :- subformula(S, P), s(P).

%% number the parents

% determine the number of parents
n_parents(S, N) :- s(S), N = { s(P) : l(P, S) }.

% n_s(S, N) means that N numbers a parent of S
n_s(S, N-1) :- n_parents(S, N), N > 0.
n_s(S, N-1) :- n_s(S, N), N > 0.

% parent P of S has number N
s2n(S, P, N) :- l(P, S), N { l(Q, S) : Q < P } N, n_s(S, N).

%% number valuations

% for statement S with N parents, there are 2^N valuations to consider
n_val(S, 2**N) :- n_parents(S, N).

% n_v(S, N) means that N numbers a valuation of the parents of S
n_v(S, N-1) :- n_val(S, N).
n_v(S, N-1) :- n_v(S, N), N>0.

% determine what atoms are true in which valuation
true(S, ValNr, P) :- s2n(S, P, PNr), n_v(S, ValNr), ValNr\(2**(PNr+1)) >= (2**PNr).

% now recursively determine the formulas that are true in a valuation
true(S, V, c(v)) :- n_v(S, V).
true(S, V, neg(F)) :- subformula(S, neg(F)), n_v(S, V), not true(S, V, F).
true(S, V, and(F, G)) :- subformula(S, and(F, G)), n_v(S, V), true(S, V, F), true(S, V, G).
true(S, V, or(F, G)) :- subformula(S, or(F, G)), n_v(S, V), true(S, V, F).
true(S, V, or(G, F)) :- subformula(S, or(G, F)), n_v(S, V), true(S, V, F).
true(S, V, imp(F, G)) :- subformula(S, imp(F, G)), n_v(S, V), not true(S, V, F).
true(S, V, imp(F, G)) :- subformula(S, imp(F, G)), n_v(S, V), true(S, V, G).
true(S, V, iff(F, G)) :- subformula(S, iff(F, G)), n_v(S, V), true(S, V, F), true(S, V, G).
true(S, V, iff(F, G)) :- subformula(S, iff(F, G)), n_v(S, V), not true(S, V, F), not true(S, V, G).

% figure out what valuations are models of a statement's acceptance formula
model(S, V) :- ac(S, F), true(S, V, F).

% put the ci and co atoms together
ci(S) :- model(S, 0).
co(S) :- s(S), not model(S, 0).

ci(S, V, P) :- l(P, S), true(S, V, P), model(S, V).
co(S, V, P) :- l(P, S), true(S, V, P), n_v(S, V), not model(S, V).
