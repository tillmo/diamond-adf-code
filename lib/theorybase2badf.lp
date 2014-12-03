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
%% theorybase.lp
%%
%% Translating defeasible theory bases into abstract dialectical frameworks.
%%
%% Defeasible theories are specified by giving for each rule a head literal and
%% body literals.
%% A literal is either positive (a term) or negative (neg(T) where T is a term).
%% Rules are represented by terms.
%% To say that a literal L is the head of a rule R, use head(R, L).
%% To say that a literal L occurs in the body of a rule R, use body(R, L).
%% A rule is considered strict unless specified otherwise.
%% To say that a rule R is defeasible, use def(R).

%% error handling: looking for rules without heads
syntax_error(rule_without_head(R)) :- has_body(R), not has_head(R).

has_body(R) :- body(R, _).
has_head(R) :- head(R, _).

%% arguments

% every rule name leads to a statement
s(R) :- rule_name(R).

rule_name(R) :- head(R, _).
rule_name(R) :- body(R, _).

fact(R) :- has_head(R), not has_body(R).

% for every rule name, there is an inapplicability statement
s(na(R)) :- rule_name(R).

% every literal occuring in the theory base leads to a statement
s(A) :- literal(A).

%% occurrence of atoms and literals in bodies and heads

occurs(L) :- occurs_in_body(L).
occurs(L) :- occurs_in_head(L).

occurs_in_body(L) :- body(_, L).
occurs_in_head(L) :- head(_, L).

undefined(L) :- occurs_in_body(L), not occurs_in_head(L).
unused(L) :- occurs_in_head(L), not occurs_in_body(L).

% anything that occurs negated is an atom
atom(A) :- occurs(neg(A)).

% anything that occurs and is not negated is an atom
atom(A) :- occurs(A), not negated(A).

% anything that occurs negated is negated
negated(neg(A)) :- occurs(neg(A)).
negated(neg(A)) :- occurs(A).

% (negated) atoms are literals
literal(plit(A)) :- atom(A).
literal(nlit(A)) :- atom(A).

opposite(plit(A), nlit(A)) :- atom(A).
opposite(nlit(A), plit(A)) :- atom(A).

%% technical helper predicates

% for switching between literals occurring in rules and their respective statements
o2s(neg(A), nlit(A)) :- literal(nlit(A)).
o2s(A, plit(A)) :- literal(plit(A)).

% for creating a disjunction of all rules with given head

last_rule(L, R) :- head(R, L), not exists_next_rule(L, R).

exists_next_rule(L, R) :- head(R, L), head(S, L), R < S.

next_rule(L, R, S) :- head(R, L), head(S, L), R < S, not exists_in_between_rule(L, R, S).

exists_in_between_rule(L, R, T) :- head(R, L), head(S, L), head(T, L), R < S, S < T.

first_rule(L, R) :- head(R, L), not exists_previous_rule(L, R).

exists_previous_rule(L, R) :- head(R, L), head(Q, L), Q < R.

or_list(L, c(f)) :- occurs(L).
or_list(L, or(R, c(f))) :- last_rule(L, R).
or_list(L, or(R, or(S, T))) :- or_list(L, or(S, T)), next_rule(L, R, S).

final_or_list(L, c(f)) :- undefined(L).
final_or_list(L, or(R, S)) :- or_list(L, or(R, S)), first_rule(L, R).

% for creating a conjunction of all literals in rule body

last_literal(R, L) :- body(R, L), not exists_next_literal(R, L).

exists_next_literal(R, L) :- body(R, L), body(R, M), L < M.

next_literal(R, L, M) :- body(R, L), body(R, M), L < M, not exists_in_between_literal(R, L, M).

exists_in_between_literal(R, L, N) :- body(R, L), body(R, M), body(R, N), M < N, N < L.

first_literal(R, L) :- body(R, L), not exists_previous_literal(R, L).

exists_previous_literal(R, L) :- body(R, L), body(R, M), M < L.

and_list(R, c(v)) :- rule_name(R).
and_list(R, and(LS, c(v))) :- last_literal(R, L), o2s(L, LS).
and_list(R, and(LS, and(MS, N))) :- and_list(R, and(MS, N)), next_literal(R, L, M), o2s(M, MS), o2s(L, LS).

final_and_list(R, c(v)) :- rule_name(R), fact(R).
final_and_list(R, and(SL, M)) :- and_list(R, and(SL, M)), o2s(L, SL), first_literal(R, L).

%% compute acceptance conditions

ac(plit(A), F) :-
	s(plit(A)),
	F = and(neg(nlit(A)), G),
	o2s(L, plit(A)),
	occurs(L),
	final_or_list(L, G).

ac(plit(A), false) :-
	o2s(L, plit(A)),
	not occurs(L).

ac(nlit(A), F) :-
	s(nlit(A)),
	F = and(neg(plit(A)), G),
	o2s(L, nlit(A)),
	occurs(L),
	final_or_list(L, G).

ac(nlit(A), false) :-
	o2s(L, nlit(A)),
	not occurs(L).

ac(R, F) :-
	rule_name(R),
	not def(R),
	final_and_list(R, F).

ac(na(R), F) :-
	rule_name(R),
	not def(R),
	head(R, H),
	o2s(H, SH),
	final_and_list(R, G),
	F = and(neg(SH), and(neg(na(R)), G)).

ac(R, F) :-
	rule_name(R),
	def(R),
	head(R, H),
	o2s(H, SH),
	opposite(SH, NH),
	final_and_list(R, G),
	F = and(neg(NH), and(neg(na(R)), G)).

ac(na(R), F) :-
	rule_name(R),
	def(R),
	F = neg(R).

%% attack and support

% rules support their head literal
sup(R, SL) :- head(R, L), o2s(L, SL).

% literals attack their opposites
att(X, Y) :- opposite(X, Y).

% rules are supported by their body literals
sup(SL, R) :- body(R, L), o2s(L, SL).

% defeasible rules are attacked by the negation of their conclusion
att(NSL, R) :- def(R), head(R, L), o2s(L, SL), opposite(NSL, SL).

% defeasible rules are attacked by the non-applicability statement
att(na(R), R) :- def(R).

% for strict rules, inapplicability statements are supported by their rule body literals
sup(SL, na(R)) :- not def(R), body(R, L), o2s(L, SL).

% for strict rules, inapplicability statements are attacked by the rule head
att(SL, na(R)) :- not def(R), head(R, L), o2s(L, SL).

% for strict rules, inapplicability statements attack themselves
att(na(R), na(R)) :- rule_name(R), not def(R).

% for defeasible rules, inapplicability statements are attacked by the rules
att(R, na(R)) :- def(R).

%% some error handling for the produced ADF

%% error handling: looking for rules without heads
syntax_error(s_without_ac(S)) :- s(S), not has_ac(S).
syntax_error(ac_without_s(S)) :- ac(S, _), not s(S).

has_ac(S) :- ac(S, _).

%% output predicates

#show syntax_error/1.
%#show s/1. #show ac/2.
