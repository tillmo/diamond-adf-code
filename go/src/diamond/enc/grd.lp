%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Copyright 2013 Stefan Ellmauthaler, ellmauthaler@informatik.uni-leipzig.de
%%           2016 Hannes Strass, strass@informatik.uni-leipzig.de
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
%% grd.lp
%%
%% Compute the grounded interpretation, that is, the (information-ordering) least fixpoint of the operator.
%% 

maxit(I) :- I = { s(S) }.

step(0).

u(S, 0) :- s(S).

t(S, I+1) :- valid(S, I).
f(S, I+1) :- unsat(S, I).
u(S, I+1) :- conti(S, I).

fp(I) :- step(I), fp(S, I) : s(S).

fp(S, I+1) :- t(S, I+1), t(S, I).
fp(S, I+1) :- f(S, I+1), f(S, I).
fp(S, I+1) :- u(S, I+1), u(S, I).

step(I+1) :- step(I), not fp(I), not maxit(I).

t(S) :- t(S, I), fp(I).
f(S) :- f(S, I), fp(I).
u(S) :- u(S, I), fp(I).

t(S) :- t(S, I), maxit(I).
f(S) :- f(S, I), maxit(I).
u(S) :- u(S, I), maxit(I).
