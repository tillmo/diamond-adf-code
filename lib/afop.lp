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
% operates directly on ASPARTIX representation
% requires definition of arg/1 and att/2
%
% usage:
% define predicate step(I), where I is an integer
% define t(S,I) for each S which is already labeled as t
% define f(S,I) for each S which is already labeled as f
% valid(S,I) represents all S which are labeled t by the operator
% unsat(S,I) represents all S which are labeled f by the operator
% if the input is a fixpoint for the operator, fp(I) is set, nofp(I) otherwise.
% ---------------------------

s(A) :- arg(A).

valid(A, I) :- arg(A), step(I), not attacked_by_t_or_u(A, I).

attacked_by_t_or_u(A, I) :- step(I), att(B, A), t(B).
attacked_by_t_or_u(A, I) :- step(I), att(B, A), u(B).

unsat(A, I) :- arg(A), step(I), att(B, A), t(B).

% figure out whether step(I) is a fixpoint

nofp(I) :- t(X,I), not valid(X,I), step(I).
nofp(I) :- valid(X,I), not t(X,I), step(I).
nofp(I) :- f(X,I), not unsat(X,I), step(I).
nofp(I) :- unsat(X,I), not f(X,I), step(I).
fp(I) :- not nofp(I), step(I).
