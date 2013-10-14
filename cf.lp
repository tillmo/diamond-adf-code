% ---------------------------
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
