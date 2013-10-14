% ---------------------------
% Prepare the answer sets for the merge to one answer
% ---------------------------
ci(S,C,X) :- ci(S,X), c(C).
co(S,C,X) :- co(S,X), c(C).

#hide c/1.
#hide ci/2.
#hide co/2.
