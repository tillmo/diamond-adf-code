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

not_rleq(X, Y) :- cand(X), cand(Y), u(Z, Y), not u(Z, X).

rleq(X, Y) :- cand(X), cand(Y), not not_rleq(X, Y).

:- rmax(X), rleq(X, Y), not rleq(Y, X).

t(Y) :- rmax(X), t(Y, X).
f(Y) :- rmax(X), f(Y, X).
u(Y) :- rmax(X), u(Y, X).
