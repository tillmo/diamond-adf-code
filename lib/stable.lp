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
%% stable.lp
%%
% ---------------------------
% stable model
% requires base opsm cf model 3KK
% ---------------------------

s_r(S) :- in(S).
l_r(X,S):- l(X,S), in(X;S).
cir(S,J):- ci(S,J,X), not l_r(X,S).
cor(S,J):- co(S,J,X), not l_r(X,S).
ci_r(S,J,X) :- ci(S,J,X), not cir(S,J).
co_r(S,J,X) :- co(S,J,X), not cor(S,J).
ci_r(S,J) :- ci_r(S,J,_).
co_r(S,J) :- co_r(S,J,_).


:- s_r(S), not valid(S,I), fp(I).
%:- not in(S), valid(S,I), fp(I), maxit(I).
