% ---------------------------
% compute the grounded semantics (former wf)
% requires base op 3KK
% ---------------------------

in(S) :- fp(I), in(S,I).
out(S) :- fp(I), out(S,I).
udec(S) :- fp(I), s(S), not in(S), not out(S).
