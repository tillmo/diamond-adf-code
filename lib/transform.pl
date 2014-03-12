%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Copyright 2013 Hannes Strass, strass@informatik.uni-leipzig.de
%%
%% This file is part of diamond.
%%
%% diamond is free software: you can redistribute it and/or modify
%% it under the terms of the GNU General Public License as published by
%% the Free Software Foundation, either version 3 of the License, or
%% (at your option) any later version.
%%
%% diamond is distributed in the hope that it will be useful,
%% but WITHOUT ANY WARRANTY; without even the implied warranty of
%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%% GNU General Public License for more details.
%%
%% You should have received a copy of the GNU General Public License
%% along with diamond.  If not, see <http://www.gnu.org/licenses/>.
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% transform.pl
%%
%% Transform abstract dialectical frameworks in ADFsys syntax into diamond syntax.

main :-
	(
	 % get the number of arguments passed to the program
	 argc(N),
	 N = 3
	->
	 % if there are exactly three, chances are the program has been called in the right syntax
	 argv(1, InputName),
	 argv(2, OutputName),
	 % first check that the input file indeed contains a pform ADF
	 checkFile(InputName),
	 % get the current time
	 cputime(Before),
	 % transform ADFsys ADF into diamond ADF
	 fastTransformFile(InputName, OutputName),
	 % get the current time again
	 cputime(After),
	 % compute the time needed for transformation
	 Time is After - Before,
	 % output transformation time
	 write(Time), nl,
	 % exit with success status
	 exit(0)
	;
	 % display an error message
	 error([ "no arguments specified!" ]),
	 % display a usage hint
	 write("Usage: ./transform.sh <InputFileName> <OutputFileName>"), nl,
	 % exit with error status
	 exit(66)
	).

parseFile(FileName, List) :-
	(
	 exists(FileName)
	->
	 (
	  open(FileName, read, Stream)
	 ->
	  readAll(Stream, List)
	 ;
	  error(["could not open file: ", FileName]),
	  exit(66)
	 )
	;
	 error(["file does not exist: ", FileName]),
	 exit(66)
	).

readAll(Stream, List) :-
	readAll(Stream, [], List).

readAll(Stream, List, FinalList) :-
	(
	 read(Stream, Atom),
	 Atom \== end_of_file		 
	->
	 append(List, [Atom], NextList),
	 readAll(Stream, NextList, FinalList)
	;
	 FinalList = List
	).

checkFile(InputFileName) :-
	parseFile(InputFileName, AtomList),
	checkADF(AtomList).

checkADF(L) :-
	\+ statementWithoutAcceptance(L),
	\+ acceptanceWithoutStatement(L),
	\+ acceptanceMentionsNonExistentStatement(L).

statementWithoutAcceptance(L) :-
	member(s(S), L),
	\+ member(ac(S, _), L),
	error([ "statement without acceptance condition: ", S ]),
	exit(65).

acceptanceWithoutStatement(L) :-
	member(ac(S, _), L),
	\+ member(s(S), L),
	error([ "acceptance condition for non-existent statement: ", S ]),
	exit(65).

acceptanceMentionsNonExistentStatement(L) :-
	member(ac(S, F), L),
	vocabulary(F, V),
	member(T, V),
	\+ member(s(T), L),
	error([ "acceptance condition ", F, " of ", S, " mentions non-existent statement ", T ]),
	exit(65).

fastTransformFile(InputFileName, OutputFileName) :-
	parseFile(InputFileName, AtomList),
	open(OutputFileName, write, OutputStream),	
	transformList(AtomList, OutputStream).

write_nl_list([]).
write_nl_list([H|T]) :-
	write(H), nl,
	write_nl_list(T).

transformList([], OutputStream) :-
	close(OutputStream).
transformList([H|T], OutputStream) :-
	transformElement(H, OutputStream),
	transformList(T, OutputStream).

:- local variable(index, 1).

transformElement(s(S), Stream) :-
	!,
	writeFact(s(S), Stream).
transformElement(ac(S, F), Stream) :-
	!,
	vocabulary(F, Parents),
	makeLinkFacts(S, Parents, Stream),
	findall(_,
		(
		 subset(I, Parents),
		 nextIndex,
		 (
		  modelFor(F, I)
		 ->
		  (
		   I = []
		  ->
		   writeFact(ci(S), Stream)
		  ;
		   makeFacts(ci, S, I, Stream)
		  )
		 ;
		  (
		   I = []
		  ->
		   writeFact(co(S), Stream)
		  ;		   
		   makeFacts(co, S, I, Stream)
		  )
		 )
		),
		_).
transformElement(Atom, Stream) :-
	error([ "unrecognised input atom: ", Atom ]),
	close(Stream),
	exit(65).

nextIndex :-
	Next is getval(index) + 1,
	setval(index, Next).

writeFact(T, Stream) :-
	term_string(T, S),
	write(Stream, S),
	write(Stream, ". "),
	nl(Stream).

makeFacts(_P, _S, [], _Stream).
makeFacts(F, S, [P|R], Stream) :-
	getval(index, N),
	Term =.. [ F, S, N, P ],
	writeFact(Term, Stream),
	makeFacts(F, S, R, Stream).

makeLinkFacts(_S, [], _Stream).
makeLinkFacts(S, [P|R], Stream) :-
	writeFact(l(P,S), Stream),
	makeLinkFacts(S, R, Stream).

vocabulary(c(_), []) :-
	!.
vocabulary(neg(F), V) :-
	!,
	vocabulary(F, V).
vocabulary(F, V) :-
	F =.. [ Binary, G, H ],
	binary(Binary),
	!,
	vocabulary(G, VG),
	vocabulary(H, VH),
	union(VG, VH, V).
vocabulary(A, [A]).

binary(and).
binary(or).
binary(xor).
binary(imp).
binary(iff).

modelFor(c(v), _).
modelFor(neg(F), I) :-
	\+ modelFor(F, I).
modelFor(and(F, G), I) :-
	modelFor(F, I),
	modelFor(G, I).
modelFor(or(F, _G), I) :-
	modelFor(F, I).
modelFor(or(_F, G), I) :-
	modelFor(G, I).
modelFor(xor(F, G), I) :-
	modelFor(F, I),
	\+ modelFor(G, I).
modelFor(xor(F, G), I) :-
	modelFor(G, I),
	\+ modelFor(F, I).
modelFor(imp(F, _G), I) :-
	\+ modelFor(F, I).
modelFor(imp(_F, G), I) :-
	modelFor(G, I).
modelFor(iff(F,G), I) :-
	 modelFor(F, I),
	 modelFor(G, I).
modelFor(iff(F,G), I) :-
	\+ modelFor(F, I),
	\+ modelFor(G, I).
modelFor(A, I) :-
	member(A, I).

error(List) :-
	write(stderr, "Error: "),
	writeList(stderr, List).

writeList(Stream, []) :-
	nl(Stream).
writeList(Stream, [H|T]) :-
	write(Stream, H),
	writeList(Stream, T).
