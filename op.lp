% ---------------------------
% Definition of the Operator (3 valued labeling)
% usage:
% define predicate step(I), where I is an integer
% define in(S,I) for each S which is already labeled as t
% define out(S,I) for each S which is already labeled as f
% valid(S,I) represents all S which are labeled t by the operator
% unsat(S,I) represents all S which are labeled f by the operator
% if the input is a fixpoint for the operator, fp(I) is set, nofp(I) otherwise.
% ---------------------------

lin(X,S,I) :- in(X,I), l(X,S), step(I).
lin(S,I) :- lin(X,S,I).
lout(X,S,I) :- out(X,I), l(X,S), step(I).
ldec(S,I) :- lin(X,S,I).
ldec(S,I) :- lout(X,S,I).

nofp(I) :- in(X,I), not valid(X,I), step(I).
nofp(I) :- valid(X,I), not in(X,I), step(I).
nofp(I) :- out(X,I), not unsat(X,I), step(I).
nofp(I) :- unsat(X,I), not out(X,I), step(I).
fp(I) :- not nofp(I), step(I).

%ci uninteresting
ciui(S,J,I) :- lin(X,S,I), not ci(S,J,X), ci(S,J).
ciui(S,J,I) :- lout(X,S,I), ci(S,J,X).
%co uninteresting
coui(S,J,I) :- lin(X,S,I), not co(S,J,X), co(S,J).
coui(S,J,I) :- lout(X,S,I), co(S,J,X).
% ci/o interesting
cii(S,J,I) :- not ciui(S,J,I), ci(S,J), step(I).
coi(S,J,I) :- not coui(S,J,I), co(S,J), step(I).

% possible and impossible model exists for S in I
pmodel(S,I) :- cii(S,J,I).
pmodel(S,I) :- verum(S), step(I).
pmodel(S,I) :- not lin(S,I), ci(S), step(I).
imodel(S,I) :- coi(S,J,I).
imodel(S,I) :- falsum(S), step(I).
imodel(S,I) :- not lin(S,I), co(S), step(I).

unsat(S,I) :- imodel(S,I), not pmodel(S,I).
valid(S,I) :- pmodel(S,I), not imodel(S,I).

%#hide.
%#show fp/1.
%#show nofp/1.
%#show valid/2.
%#show unsat/2.
