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
%% rmax.lp
%% computing range-maximal (undefined-minimal) interpretations
%%

cand(X) :- t(_, X).
cand(X) :- f(_, X).
cand(X) :- u(_, X).

1 { rmax(X) : cand(X) } 1.

notINileq(X, Y) :- cand(X), cand(Y), t(Z, X), not t(Z, Y).
notOUTileq(X, Y) :- cand(X), cand(Y), f(Z, X), not f(Z, Y).

ileq(X, Y) :- cand(X), cand(Y), not notINileq(X, Y), not notOUTileq(X, Y).

notUileq(X, Y) :- cand(X), cand(Y), u(Z, Y), not u(Z, X).

rleq(X, Y) :- ileq(X, Y), not notUileq(X, Y).

:- rmax(X), rleq(X, Y), X != Y.

t(Y) :- rmax(X), t(Y, X).
f(Y) :- rmax(X), f(Y, X).
u(Y) :- rmax(X), u(Y, X).