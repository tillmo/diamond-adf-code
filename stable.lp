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
