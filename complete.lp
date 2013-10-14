% ---------------------------
% Computes the complete extension
% requires op base
% ---------------------------
step(0).
{in(S,0):s(S)}.
{out(S,0):s(S)}.

:- in(S,0), out(S,0).
:- nofp(0).

in(S) :- in(S,_).
out(S) :- out(S,_).
udec(S) :- s(S), not in(S), not out(S).
