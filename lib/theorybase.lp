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
%% Translating defeasible theory bases into abstract argumentation frameworks.
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
syntax_error(rule_without_head(R)) :- hasBody(R), not hasHead(R).

hasBody(R) :- body(R, _).
hasHead(R) :- head(R, _).

%% arguments

% every rule name leads to an argument
arg(R) :- head(R, _).
arg(R) :- body(R, _).

% every literal occuring in the theory base leads to an argument
arg(A) :- literal(A).

literal(L) :- head(_, L).
literal(L) :- body(_, L).

% any non-negated literal is considered to be an atom
atom(A) :- literal(neg(A)).

atom(A) :- body(_, A), not negative(A).
negative(neg(A)) :- body(_, neg(A)).
atom(A) :- head(_, A), not negative(A).
negative(neg(A)) :- head(_, neg(A)).

% (negated) atoms are literals
literal(A) :- atom(A).
literal(neg(A)) :- atom(A).

%% attacks

% opposite literals attack one another

att(A, neg(A)) :- atom(A).
att(neg(A), A) :- atom(A).

% negations of body literals attack the rule atom

att(A, R) :- body(R, neg(A)).
att(neg(A), R) :- body(R, A), atom(A).

% rules attack the negations of their heads

att(R, A) :- head(R, neg(A)).
att(R, neg(A)) :- head(R, A), atom(A).

% defeasible rules are attacked by the negations of their heads

att(A, R) :- def(R), head(R, neg(A)).
att(neg(A), R) :- def(R), head(R, A), atom(A).

%% integrity constraint
% it may not be that a rule argument is accepted, but the rule's conclusion is not

:- t(R), head(R, L), f(L). % diamond syntax
%:- in(R), head(R, L), out(L). % aspartix syntax