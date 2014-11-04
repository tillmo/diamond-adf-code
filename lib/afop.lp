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
%% afop.lp
%%
% ---------------------------
% Definition of the ultimate characteristic operator for Dung AFs
% operates directly on the ASPARTIX representation
% requires definition of arg/1 and att/2
%
% usage:
% define predicate step(I), where I is an integer
% define t(S,I) for each S which is already labeled as t
% define f(S,I) for each S which is already labeled as f
% valid(S,I) represents all S that are labelled t by the operator
% unsat(S,I) represents all S that are labelled f by the operator
% conti(S,I) represents all S that are labelled u by the operator
% if the input is a fixpoint for the operator, fp(I) is set, nofp(I) otherwise.
% ---------------------------

s(A) :- arg(A).

% all attackers of A are false iff for each argument B, either
% (1) B attacks a, and B is false; or
% (2) B does not attack A
aaf_ok(A, B, I) :- att(B, A), f(B, I).
aaf_ok(A, B, I) :- s(A), s(B), step(I), not att(B, A).

% the same for all attackers of A being false or undefined
aafou_ok(A, B, I) :- att(B, A), u(B, I).
aafou_ok(A, B, I) :- att(B, A), f(B, I).
aafou_ok(A, B, I) :- s(A), s(B), step(I), not att(B, A).

all_attackers_f(A, I) :- step(I), s(A), aaf_ok(A, B, I) : s(B).
all_attackers_f_or_u(A, I) :- step(I), s(A), aafou_ok(A, B, I) : s(B). % Ils sont completement fou!

% AFs are a special case of ADFs where acceptance conditions are conjunctions of negative literals
% this entails the acceptance statuses below:
% a conjunction of negative literals is true iff all atoms are false
valid(A, I) :- arg(A), step(I), all_attackers_f(A, I).
% it is false if one atom is true
unsat(A, I) :- arg(A), step(I), some_attacker_t(A, I).
% it is undecided in all other cases
conti(A, I) :- arg(A), step(I), some_attacker_u(A, I), all_attackers_f_or_u(A, I).

some_attacker_t(A, I) :- att(B, A), t(B, I).
some_attacker_u(A, I) :- att(B, A), u(B, I).

% figure out whether step(I) is a fixpoint

nofp(I) :- t(X,I), not valid(X,I), step(I).
nofp(I) :- valid(X,I), not t(X,I), step(I).
nofp(I) :- f(X,I), not unsat(X,I), step(I).
nofp(I) :- unsat(X,I), not f(X,I), step(I).
fp(I) :- not nofp(I), step(I).
