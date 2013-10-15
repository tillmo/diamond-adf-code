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
%% cf.lp
%%% ---------------------------
% ASP - Encoding
% conflict-free sets of ADFs
% with acceptance sets
% requires base.dl
% ---------------------------

{in(X):s(X)}.

linkin(X,S) :- in(X), l(X,S).
% not satisfied ci:
nsci(S,J) :- linkin(X,S), not ci(S,J,X), ci(S,J).
nsci(S,J) :- ci(S,J,X), not linkin(X,S).

ismodel(S) :- ci(S,J), not nsci(S,J).
ismodel(S) :- ci(S), {linkin(X,S)}0.
ismodel(S) :- verum(S).


:- in(X), not ismodel(X).

%#hide.
%#show in/1.
%#show ismodel/1.
