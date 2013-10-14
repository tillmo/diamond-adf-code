% ---------------------------
% Basic logical definitions
% ---------------------------

% positive interpretations
%pint(S,C) :- ci(S,C,_).
% negative interpretations
%nint(S,C) :- co(S,C,_).

ci(S,J) :- ci(S,J,_).
co(S,J) :- co(S,J,_).
verum(S) :- ci(S), {ci(S,_,_)}0, {co(S,_,_)}0.
falsum(S) :- co(S), {ci(S,_,_)}0, {co(S,_,_)}0.
