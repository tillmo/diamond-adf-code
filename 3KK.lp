% ---------------------------
% computation of the 3 valued Kripke Kleene semantics 
% requires base.dl op(sm)
% ---------------------------

maxit(I) :- I:={s(S)}.
step(0).

in(S,I+1) :- valid(S,I).
out(S,I+1) :- unsat(S,I).
step(I+1) :- step(I), not maxit(I).
