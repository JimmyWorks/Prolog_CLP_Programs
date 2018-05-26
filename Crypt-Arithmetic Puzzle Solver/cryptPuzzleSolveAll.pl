/*
	Generic Crypt-Arithmetic Solve Method
	
	Author: Jimmy Nguyen
	Email: Jimmy@Jimmyworks.net
	
	Solve any Crypt-Arithmetic puzzle
	Where the sum of A + B = C, and
	A, B, and C are lists containing
	the integer variables with unique values.
	
	Modified Solver
	Finds all solutions and prints number of
	total solutions along with all solutions.
*/

:- use_module(library(clpfd)).

/*
	Auxiliary Solver: Generates all results at once
*/
solveall(A + B = C) :-
    findall(A + B = C, solve(A + B = C), L),
	nl, write('Found '), length(L, Length), write(Length), write(' solutions!'), nl, 
	printListOfSolutions(L).

/*
	Primary Crypt-Arithmetic Solver
*/
solve(A + B = C) :-

	/* Let Vars be the set of all possible values */
	Vars = [0,1,2,3,4,5,6,7,8,9],
	
	/* Let A, B, and C be lists */
	A = [X|_],
	B = [Y|_],
	C = [Z|_],
	
	/* The first variable cannot be 0 */
	X #\= 0,
	Y #\= 0,
	Z #\= 0,
	
	/* Let Set be the set of all variables */
	union_variables(A,B,Subset),
	union_variables(Subset,C,Set),

	/* Unify each variable to a unique value */
	unify(Set,Vars),
	
	/* Arithmetic operations */
	SumC #= SumA + SumB,
	value(A, 0, SumA),
	value(B, 0, SumB),
	value(C, 0, SumC).

/* Value method to retrieve value in array */
value([X|Rest],Prev,Result) :- length(Rest, 0), 
								Result #= Prev + X.
value([X|Rest],Prev,Result) :- length(Rest, Power),
								NewPrev #= Prev + X*(10^Power),
								value(Rest, NewPrev, Result).

/*
	Union variable sets
*/								
union_variables(V1, V2, Union):- term_variables([V1|V2], Union).

/*
	Unify variables in the first set with unique values in the second set.
*/
unify([X|Rest],Vars):- length(Rest, 0), select(X,Vars,_).
unify([X|Rest],Vars):- length(Rest, L), L > 0, 
					   select(X,Vars,Remaining), 
					   unify(Rest, Remaining).
/*
	Print each solution in the list
*/
printListOfSolutions([X|Rest]):- 	length(Rest, 0), 
									write(X), nl.
printListOfSolutions([X|Rest]):- 	length(Rest, R), R > 0, 
									write(X), nl,
									printListOfSolutions(Rest).