% ---------------------------
% compute the admissible sets
% requires base op
% ---------------------------

step(0).
{in(S,0):s(S)}.
{out(S,0):s(S)}.

:- in(S,0), out(S,0).

in(S) :- in(S,0).
out(S) :- out(S,0).
udec(S) :- s(S), not in(S), not out(S).

:- in(S), not valid(S,0).
:- out(S), not unsat(S,0).
