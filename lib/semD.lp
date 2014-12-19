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
%% semD.lp
%% disjunctive encoding of semi-model semantics
%%

%% complete

step(0).

t(S, 0) | f(S, 0) | u(S, 0) :- s(S).

% admissible 

:- t(S,0), not valid(S,0).
:- f(S,0), not unsat(S,0).

% complete

:- valid(S, 0), not t(S, 0).
:- unsat(S, 0), not f(S, 0).

%% rmax

step(1).

% guess another interpretation that has an equal or greater range

t(S, 1) | f(S, 1) :- t(S, 0).
t(S, 1) | f(S, 1) :- f(S, 0).
t(S, 1) | f(S, 1) | u(S, 1) :- u(S,0).

% saturate if alright

t(S, 1) :- s(S), ok.
f(S, 1) :- s(S), ok.
u(S, 1) :- s(S), ok.

ok :- not ok.

% the first interpretation is ok if and only if:
% for every interpretation higher up in the information ordering, one of the following holds:

% (1) the interpretation is also complete and has the same range
ok :- requal.

% (2) the interpretation has a greater range, but is not complete
ok :- rgreater, incomplete.

% the second interpretation has the same range as the first one

requal :- requal(S) : s(S).

requal(S) :- t(S, 0), t(S, 1).
requal(S) :- f(S, 0), f(S, 1).
requal(S) :- u(S, 0), u(S, 1).
requal(S) :- t(S, 0), f(S, 1).
requal(S) :- f(S, 0), t(S, 1).

% the second interpretation has a strictly greater range if
% there is a statement that is undecided in the first and decided in the second

rgreater :- u(S, 0), t(S, 1).
rgreater :- u(S, 0), f(S, 1).

% the second interpretation is not complete if truth value and satisfiability/refutability status do not match

incomplete :- t(S,1), unsat(S,1).
incomplete :- f(S,1), valid(S,1).
incomplete :- t(S,1), conti(S,1).
incomplete :- f(S,1), conti(S,1).
incomplete :- u(S,1), unsat(S,1).
incomplete :- u(S,1), valid(S,1).

% output predicates

t(S) :- t(S,0).
f(S) :- f(S,0).
u(S) :- u(S,0).
