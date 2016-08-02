%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Copyright 2014, 2016 Hannes Strass, strass@informatik.uni-leipzig.de
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
%% Definition of the ultimate characteristic operator for Dung AFs
%% operates directly on the ASPARTIX representation
%% requires definition of arg/1 and att/2
%%
%% input:
%% * a step, declared via step/1
%% * a three-valued interpretation, declared via t/2, f/2, u/2 for the respective step
%%
%% output:
%% * a three-valued interpretation, represented via valid/2, unsat/2, conti/2 (t, f, u) for the respective step
%% * ref/2 and sat/2 for the respective step, as this is needed in some encodings
%%

s(A) :- arg(A).

f_or_u(A, I) :- f(A, I).
f_or_u(A, I) :- u(A, I).

all_attackers_f(A, I) :- step(I), s(A), f(B, I) : att(B, A).
all_attackers_f_or_u(A, I) :- step(I), s(A), f_or_u(B, I) : att(B, A).

some_attacker_t(A, I) :- att(B, A), t(B, I).
some_attacker_u_or_t(A, I) :- att(B, A), u(B, I).
some_attacker_u_or_t(A, I) :- att(B, A), t(B, I).

% AFs are a special case of ADFs where acceptance conditions are conjunctions of negative literals
% this entails the acceptance statuses below:
% a conjunction of negative literals is true iff all atoms are false

valid(A, I) :- all_attackers_f(A, I).
ref(A, I) :- some_attacker_u_or_t(A, I).

% it is false if one atom is true
unsat(A, I) :- some_attacker_t(A, I).
sat(A, I) :- all_attackers_f_or_u(A, I).

% it is undecided in all other cases
conti(A, I) :- sat(A, I), ref(A, I).

