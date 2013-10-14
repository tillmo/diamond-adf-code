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


