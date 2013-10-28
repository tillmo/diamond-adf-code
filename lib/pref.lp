adm(X) :- in(_,X).
adm(X) :- out(_,X).
adm(X) :- udec(_,X).

1{pref(X):adm(X)}1.

incomparable(X,Y) :- adm(X), adm(Y), in(Z,X), out(Z,Y).
incomparable(Y,X) :- incomparable(X,Y).

st(X,Y) :- adm(X), adm(Y), udec(Z,X), not udec(Z,Y), X != Y.

:- pref(X), adm(Y), X!=Y, st(X,Y), not incomparable(X,Y).

in(Y) :- pref(X), in(Y,X).
out(Y) :- pref(X), out(Y,X).
udec(Y) :- pref(X), udec(Y,X).


