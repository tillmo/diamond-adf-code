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
%% prfD.lp
%% disjunctive encoding of preferred semantics
%% an interpretation is preferred iff it is (1) complete and (2) information-maximal complete

%% (1) complete

step(0).

1 { t(S, 0) ; f(S, 0) ; u(S, 0) } 1 :- s(S).

% admissible 

:- t(S,0), not valid(S,0).
:- f(S,0), not unsat(S,0).

% complete

:- valid(S, 0), not t(S, 0).
:- unsat(S, 0), not f(S, 0).

%% (2) information-maximal complete

% guess another interpretation that contains at least as much information

step(1).

t(S, 1) | f(S, 1) | u(S, 1) :- u(S, 0).

t(S, 1) :- t(S, 0).
f(S, 1) :- f(S, 0).

% saturate if alright

t(S, 1) :- s(S), ok.
f(S, 1) :- s(S), ok.

% force groundedness of ok

ok :- not ok.

% the first interpretation I is ok if and only if:
% for every interpretation J comparable to I in the information ordering (I ileq J), one of the following holds:

% (1) the interpretation is the same
ok :- equal.

% (2) the interpretation contains more information, but is not admissible
ok :- greater, inadmissible.

% the second interpretation equals the first one if they agree on all truth values for all statements

equal :- equal(S) : s(S).

equal(S) :- t(S, 0), t(S, 1).
equal(S) :- f(S, 0), f(S, 1).
equal(S) :- u(S, 0), u(S, 1).

% the second interpretation is greater in the information ordering

greater :- greater(S).

greater(S) :- u(S, 0), t(S, 1).
greater(S) :- u(S, 0), f(S, 1).

% the second interpretation is not admissible if it makes unjustified assignments

inadmissible :- inadmissible(S).

inadmissible(S) :- t(S, 1), ref(S, 0).
inadmissible(S) :- f(S, 1), sat(S, 0).

ref(S, I) :- conti(S, I).
ref(S, I) :- unsat(S, I).

sat(S, I) :- conti(S, I).
sat(S, I) :- valid(S, I).

% output predicates

t(S) :- t(S,0).
f(S) :- f(S,0).
u(S) :- u(S,0).
