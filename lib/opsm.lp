%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Copyright 2013 Stefan Ellmauthaler, ellmauthaler@informatik.uni-leipzig.de
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
%% opsm.lp
%%
% ---------------------------
% Definition of the Operator (3 valued labeling)
% usage:
% needs the following predicates {s,l,ci,co}_r
% define predicate step(I), where I is an integer
% define t(S,I) for each S which is already labeled as t
% define f(S,I) for each S which is already labeled as f
% valid(S,I) represents all S which are labeled t by the operator
% unsat(S,I) represents all S which are labeled f by the operator
% if the input is a fixpoint for the operator, fp(I) is set, nofp(I) otherwise.
% ---------------------------

lin(X,S,I) :- t(X,I), l_r(X,S), step(I).
lin(S,I) :- lin(X,S,I).
lout(X,S,I) :- f(X,I), l_r(X,S), step(I).
ldec(S,I) :- lin(X,S,I).
ldec(S,I) :- lout(X,S,I).

nofp(I) :- t(X,I), not valid(X,I), step(I).
nofp(I) :- valid(X,I), not t(X,I), step(I).
nofp(I) :- f(X,I), not unsat(X,I), step(I).
nofp(I) :- unsat(X,I), not f(X,I), step(I).
fp(I) :- not nofp(I), step(I).

%ci uninteresting
ciui(S,J,I) :- lin(X,S,I), not ci_r(S,J,X), ci_r(S,J).
ciui(S,J,I) :- lout(X,S,I), ci_r(S,J,X).
%co uninteresting
coui(S,J,I) :- lin(X,S,I), not co_r(S,J,X), co_r(S,J).
coui(S,J,I) :- lout(X,S,I), co_r(S,J,X).
% ci/o interesting
cii(S,J,I) :- not ciui(S,J,I), ci_r(S,J), step(I).
coi(S,J,I) :- not coui(S,J,I), co_r(S,J), step(I).

% possible and impossible model exists for S in I
pmodel(S,I) :- cii(S,J,I).
pmodel(S,I) :- s_r(S), verum(S), step(I).
pmodel(S,I) :- s_r(S), not lin(S,I), ci(S), step(I).
imodel(S,I) :- coi(S,J,I).
imodel(S,I) :- s_r(S), falsum(S), step(I).
imodel(S,I) :- s_r(S), not lin(S,I), co(S), step(I).

unsat(S,I) :- imodel(S,I), not pmodel(S,I).
valid(S,I) :- pmodel(S,I), not imodel(S,I).
