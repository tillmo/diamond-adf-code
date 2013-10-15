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
%% prio_trans.lp
%%
% ---------------------------
% Transformation of a prioritized ADF
% to the representation used by this system
% call it via gringo | clasp --outf=1 to get gringo conform input format
% ---------------------------
% input format:
% s(a) for statement a
% lp(A,N)/lm(A,N) for support/attack link
% pref(A,B) for the preference A > B 
% ---------------------------
l(X,S) :- lp(X,S).
l(X,S) :- lm(X,S).

% create the transitive closure for the preferences:
pref(A,B) :- pref(A,C), pref(C,B).

ci(S) :- s(S).

1{aktS(S):s(S)}1.

{in(A):s(A)}:- aktS(S), l(A,S).
out(A) :- l(A,S), aktS(S), not in(A).

strong_enough_att(S,A) :- lm(A,S), aktS(S), in(A), not pref(S,A).
stronger_supp(S,A) :- strong_enough_att(S,A), in(B), lp(B,S), pref(B,A).

defeated(S) :- strong_enough_att(S,A), not stronger_supp(S,A). 
undefeated(S) :- aktS(S), not defeated(S).

ci(S,A) :- undefeated(S), in(A).
co(S,A) :- defeated(S), in(A).

#hide.
#show ci/2.
#show co/2.
#show ci/1.
#show l/2.
#show s/1.


