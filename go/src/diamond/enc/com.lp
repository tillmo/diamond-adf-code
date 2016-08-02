%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Copyright 2013 Stefan Ellmauthaler, ellmauthaler@informatik.uni-leipzig.de
%%           2014 Hannes Strass, strass@informatik.uni-leipzig.de
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
%% com.lp
%%
%% Compute complete interpretations, that is, three-valued fixpoints of the operator.
%%

step(0).

1 { t(S, 0) ; f(S, 0) ; u(S, 0) } 1 :- s(S).

% admissible

:- t(S, 0), ref(S, 0).
:- f(S, 0), sat(S, 0).

% complete

:- u(S, 0), not conti(S, 0).
:- s(S), not t(S, 0), not ref(S, 0).
:- s(S), not f(S, 0), not sat(S, 0).

% output predicates

t(S) :- t(S, 0).
f(S) :- f(S, 0).
u(S) :- u(S, 0).
