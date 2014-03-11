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
%% fmodel.lp
%%
% ---------------------------
% Definition of the two-valued model semantics directly on acceptance formulas
% requires definition of statement/1 or s/1, and ac/2
% provides definition of t/1 and f/1

s(S) :- statement(S).

% guess a two-valued interpretation
{t(S)} :- s(S).

% figure out whether various interpretations are models for acceptance formulas

true(c(v)).
true(P) :- t(P).
true(neg(F)) :- relevant(neg(F)), not true(F).
true(and(F,G)) :- relevant(and(F,G)), true(F), true(G).
true(or(F,G)) :- relevant(or(F,G)), true(F).
true(or(F,G)) :- relevant(or(F,G)), true(G).
true(imp(F,G)) :- relevant(imp(F,G)), true(G).
true(imp(F,G)) :- relevant(imp(F,G)), not true(F).
true(iff(F,G)) :- relevant(iff(F,G)), true(F), true(G).
true(iff(F,G)) :- relevant(iff(F,G)), not true(F), not true(G).
true(xor(F,G)) :- relevant(xor(F,G)), true(F), not true(G).
true(xor(F,G)) :- relevant(xor(F,G)), true(G), not true(F).

% figure out what formulas are relevant for statement S:
% obviously, its acceptance formula F and all of F's subformulas

relevant(F) :- ac(S, F).

relevant(F) :- relevant(neg(F)).
relevant(F) :- relevant(and(F,_)).
relevant(F) :- relevant(and(_,F)).
relevant(F) :- relevant(or(F,_)).
relevant(F) :- relevant(or(_,F)).
relevant(F) :- relevant(imp(F,_)).
relevant(F) :- relevant(imp(_,F)).
relevant(F) :- relevant(iff(F,_)).
relevant(F) :- relevant(iff(_,F)).
relevant(F) :- relevant(xor(F,_)).
relevant(F) :- relevant(xor(_,F)).

% remove those interpretations where truth value of statement and
% truth value of acceptance formula do not coincide

:- ac(S, F), t(S), not true(F).
:- ac(S, F), true(F), not t(S).

% complete the interpretation
% all non-true statements are false

f(S) :- s(S), not t(S).

#show t/1. #show f/1.