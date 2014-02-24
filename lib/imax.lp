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
%% imax.lp
%% computing information-maximal interpretations
%%
cand(X) :- in(_, X).
cand(X) :- out(_, X).
cand(X) :- udec(_, X).

1 { imax(X) : cand(X) } 1.

notINileq(X, Y) :- cand(X), cand(Y), in(Z, X), not in(Z, Y).
notOUTileq(X, Y) :- cand(X), cand(Y), out(Z, X), not out(Z, Y).

ileq(X, Y) :- cand(X), cand(Y), not notINileq(X, Y), not notOUTileq(X, Y).

:- imax(X), ileq(X, Y), X != Y.

in(Y) :- imax(X), in(Y, X).
out(Y) :- imax(X), out(Y, X).
udec(Y) :- imax(X), udec(Y, X).
