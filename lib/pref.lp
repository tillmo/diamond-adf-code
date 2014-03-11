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

adm(X) :- t(_,X).
adm(X) :- f(_,X).
adm(X) :- u(_,X).

1{pref(X):adm(X)}1.

incomparable(X,Y) :- adm(X), adm(Y), t(Z,X), f(Z,Y).
incomparable(X,Y) :- adm(X), adm(Y), st(X,Y), st(Y,X).
incomparable(Y,X) :- incomparable(X,Y).

st(X,Y) :- adm(X), adm(Y), u(Z,X), not u(Z,Y), X != Y.

:- pref(X), adm(Y), X!=Y, st(X,Y), not incomparable(X,Y).

t(Y) :- pref(X), t(Y,X).
f(Y) :- pref(X), f(Y,X).
u(Y) :- pref(X), u(Y,X).


