% ---------------------------
% compute the preferred model
% requires base op admissible
% ---------------------------

%dec(S) :- in(S).
%dec(S) :- out(S).

not_in(S):- s(S), not in(S).
not_out(S):- s(S), not out(S).

#minimize [not_in(S)].
#minimize [not_out(S)].
