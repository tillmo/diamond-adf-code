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
%% naiD.lp
%%
%% disjunctive encoding of naive semantics
%% an interpretation is naive iff it is (1) conflict-free and (2) information-maximal conflict-free
%%
%% this encoding requires a monotone definition of valid/2 and unsat/2 in the operator
%%

%% (1) conflict-free

step(0).

1 { t(S, 0) ; f(S, 0) ; u(S, 0) } 1 :- s(S).

% conflict-free

:- t(S,0), unsat(S, 0).
:- f(S,0), valid(S, 0).

% guess another interpretation that contains at least as much information

step(1).

t(S, 1) | f(S, 1) | u(S, 1) :- u(S, 0).

t(S, 1) :- t(S, 0).
f(S, 1) :- f(S, 0).

% saturate if alright

t(S, 1) :- s(S), ok.
f(S, 1) :- s(S), ok.
u(S, 1) :- s(S), ok.

% force groundedness of ok

ok :- not ok.

% the first interpretation I is ok if and only if:
% for every interpretation J comparable to I in the information ordering (I ileq J), one of the following holds:

% (1) the interpretation is the same
ok :- equal.

% (2) the interpretation contains more information, but is not conflict-free
ok :- greater, conflict.

% the second interpretation equals the first one if they agree on all truth values for all statements

equal :- equal(S) : s(S).

equal(S) :- t(S, 0), t(S, 1).
equal(S) :- f(S, 0), f(S, 1).
equal(S) :- u(S, 0), u(S, 1).

% the second interpretation is greater in the information ordering

greater :- greater(S).

greater(S) :- u(S, 0), t(S, 1).
greater(S) :- u(S, 0), f(S, 1).

% the second interpretation is not conflict-free if it makes unjustified assignments

conflict :- conflict(S).

conflict(S) :- t(S, 1), unsat(S, 1).
conflict(S) :- f(S, 1), valid(S, 1).

% output predicates

t(S) :- t(S, 0).
f(S) :- f(S, 0).
u(S) :- u(S, 0).
