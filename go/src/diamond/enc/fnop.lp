%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Copyright 2016 Hannes Strass, strass@informatik.uni-leipzig.de
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
%% fnop.lp
%%
%% Definition of the characteristic ADF operator for the functional ADF representation.
%% That is, the ADF is defined via ci/1, co/1, ci/3, co/3.
%%
%% input:
%% * a step/1
%% * a three-valued interpretation, declared via t/2, f/2, u/2
%%
%% output:
%% * a three-valued interpretation represented via valid/2, unsat/2, conti/2
%% * ref/2 and sat/2
%%

u_or_t(P, I) :- u(P, I).
u_or_t(P, I) :- t(P, I).
u_or_f(P, I) :- u(P, I).
u_or_f(P, I) :- f(P, I).

% figure out the remaining parents (those that are not mentioned in a specific disjunct)
cor(S, V, P) :- l(P, S), co(S, V, _), not co(S, V, P).
cor(S, 0, P) :- l(P, S), co(S).
cir(S, V, P) :- l(P, S), ci(S, V, _), not ci(S, V, P).
cir(S, 0, P) :- l(P, S), ci(S).

% a ci/co triple (referring to a specific interpretation V) is still relevant iff
% it is above the "current" interpretation in the information ordering, that is,
% all parents that must be true are t or u in the current interpretation, and
% all parents that must be false are f or u in the current interpretation
rel(t, S, V, I) :- ci(S, V, _), step(I), u_or_t(P, I) : ci(S, V, P); u_or_f(P, I) : cir(S, V, P).
rel(t, S, 0, I) :- ci(S), step(I), u_or_f(P, I) : l(P, S).
rel(f, S, V, I) :- co(S, V, _), step(I), u_or_t(P, I) : co(S, V, P); u_or_f(P, I) : cor(S, V, P).
rel(f, S, 0, I) :- co(S), step(I), u_or_f(P, I) : l(P, S).

% the operator result for a statement is clear if all relevant interpretations lead to the same outcome
% if the outcome is different, the acceptance formula is both refutable and satisfiable, that is, contingent
sat(S, I) :- rel(t, S, _, I).
ref(S, I) :- rel(f, S, _, I).

conti(S, I) :- sat(S, I), ref(S, I).
valid(S, I) :- sat(S, I), not ref(S, I).
unsat(S, I) :- ref(S, I), not sat(S, I).
