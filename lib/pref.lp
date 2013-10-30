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
%% pref.lp
%%

adm(X) :- in(_,X).
adm(X) :- out(_,X).
adm(X) :- udec(_,X).

1{pref(X):adm(X)}1.

incomparable(X,Y) :- adm(X), adm(Y), in(Z,X), out(Z,Y).
incomparable(X,Y) :- adm(X), adm(Y), st(X,Y), st(Y,X).
incomparable(Y,X) :- incomparable(X,Y).

st(X,Y) :- adm(X), adm(Y), udec(Z,X), not udec(Z,Y), X != Y.

:- pref(X), adm(Y), X!=Y, st(X,Y), not incomparable(X,Y).

in(Y) :- pref(X), in(Y,X).
out(Y) :- pref(X), out(Y,X).
udec(Y) :- pref(X), udec(Y,X).


