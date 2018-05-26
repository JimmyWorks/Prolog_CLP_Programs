/*
	Sudoku Program
	
	Author: Jimmy Nguyen
	Email: Jimmy@Jimmyworks.net
	
	This program supports various functions for Sudoku.
	Users are able to generate new Sudoku solutions and use
	that solution to create a Sudoku problem.  Problems
	randomly select a Sudoku pattern, 1 of 3, that are
	available.  If desired, the problem can be given to
	the Sudoku solver and a solution for the problem will
	be generated.
*/

:- use_module(library(clpfd)). 

/*
	Primary Sudoku Definition Clause
	Rows are a list of Rows, where each Row is a list of cells.
	Constraints for Rows, Columns, and Blocks are defined.
	This clause is used to solve or generate new Sudoku solutions.
*/
sudoku(Rows) :- 
				length(Rows, 9), 			 /*There are 9 rows */
				maplist(length_list(9), Rows), /* Every Row has 9 elements */ 
				Rows = [A,B,C,D,E,F,G,H,I], /* Identify rows Vars = [1,2,3,4,5,6,7,8,9],*/
				blocks(A, B, C), 			/* Every three rows form 3 blocks */
				blocks(D, E, F), 
				blocks(G, H, I),
				append(Rows, Vs), 				/* List Vs contains all elements */
				Vs ins 1..9, 					/* All elements between 1-9 */
				maplist(all_distinct, Rows), 	/* Every row is distinct */
				transpose(Rows, Columns), 		/* Columns is the list of lists for columns */
				maplist(all_distinct, Columns), /* Every column is distinct  */
				maplist(label, Rows),			/* Label elements and give a distinct solution */
				maplist(printPuzzle, Rows), nl.	/* Print the solution */

/* 
	Create a New Random Sudoku Solution Clause
	This clause randomly generates a new Sudoku solution utilizing
	the randomize/1 clause and the sudoku/1 clause.
*/
createNew(Rows) :- 
				Rows= [A|_],	/* The first row is A */
				length(A, 9),	/* The length of the first row is 9 */
				randomize(A),	/* Randomize the values in the first row */
				nl, write('Solved Puzzle Generated:'), nl,
				sudoku(Rows).	/* With this seed, generate the rest of the puzzle */

/* 
	Solves a Given Sudoku Problem Clause
	This clause takes a given puzzle and decodes the puzzle.
	With the decoded puzzle, sudoku/1 is used to generate
	the solution.
*/				
solve(Puzzle):- append(Puzzle, Flat_Puzzle),	/* Flatten the puzzle */
				decodePuzzle(Flat_Puzzle, Flat_Problem),	/* Decode the puzzle */
				convertFlatToLL(Flat_Problem, Problem),	/* Convert to list of rows */
				nl, write('Solved Problem:'), nl,
				sudoku(Problem).	/* Solve the problem */
/*
	Make a Sudoku Problem Clause
	This clause takes a Sudoku solution and generates a puzzle from it.
	Using pickPattern/2, the clause finds a pattern to
	use for the puzzle.  Using this pattern, the puzzle will unify values
	or blank spaces depending on index.
*/				
makeProblem(Rows, Puzzle):- append(Rows, Flat_Rows),
							length(Flat_Puzzle, 81),
							random_between(1, 3, Val),
							pickPattern(Val, Clue_Index),
							defPuzzle(Flat_Rows, Flat_Puzzle, Clue_Index, 1, 81),
							convertFlatToLL(Flat_Puzzle, Puzzle),
							nl, write('Problem Generated:'), nl,
							maplist(printPuzzle, Puzzle), nl.
							
/* 
	Formatted Print for each row in puzzle.  Use maplist/2 to print each row 
*/
printPuzzle(List):- write_term(List, [quoted(false), nl(true), spacing(next_argument)]), !.

/* 
	Randomize a Row 
*/
randomize(A) :-	Bag = [1,2,3,4,5,6,7,8,9], /* Contents of the row */
				unify(A, Bag).	/* Unify each atom in the row to a value */
				
/* 
	Unify variables in the first set with unique values in the second set. 
*/
unify([X|Rest],Vars):- 	length(Rest, 0), 
						nth0(0,Vars,Element),
						X = Element.
unify([X|Rest],Vars):- 	length(Rest, L), L > 0, 
						random_between(0, L, Index),
						nth0(Index,Vars,Element, Remaining),
						X = Element,
						unify(Rest, Remaining).

/*
	Unify Each Element in the Puzzle Depending on Index and the Pattern Index 
*/
defPuzzle(Flat_Rows, Puzzle, Shown_Index, Index, Last_Index):-
							\+ (Index == Last_Index),
							member(Index, Shown_Index),
							nth1(Index, Flat_Rows, Integer),
							nth1(Index, Puzzle, Integer),
							NewIndex is Index+1,
							defPuzzle(Flat_Rows, Puzzle, Shown_Index, NewIndex, Last_Index).
defPuzzle(Flat_Rows, Puzzle, Shown_Index, Index, Last_Index):-
							\+ (Index == Last_Index),
							\+ (member(Index, Shown_Index)),
							nth1(Index, Puzzle, '_'),
							NewIndex is Index+1,
							defPuzzle(Flat_Rows, Puzzle, Shown_Index, NewIndex, Last_Index).							
defPuzzle(Flat_Rows, Puzzle, Shown_Index, Index, Last_Index):-
							Index == Last_Index,
							member(Index, Shown_Index),
							nth1(Index, Flat_Rows, Integer),
							nth1(Index, Puzzle, Integer).
defPuzzle(Flat_Rows, Puzzle, Shown_Index, Index, Last_Index):-
							Index == Last_Index,
							\+ (member(Index, Shown_Index)),
							nth1(Index, Puzzle, '_').
/*
	Decode Puzzles where '_' are unbound atoms
*/
decodePuzzle([], []).
decodePuzzle([X|XT], [Y|YT]):-	
								number(X),
								Y = X,
								decodePuzzle(XT, YT).
decodePuzzle([X|XT], [_|YT]):-	
								\+ number(X),
								decodePuzzle(XT, YT).								

/*
	Pick a Sudoku pattern depending on value passed in.
	Three patterns are supported.
*/
pickPattern(1, [1,3,5,6,7,11,16,19,20,22,26,27,28,30,37,39,40,41,42,43,45,52,54,55,56,60,62,63,66,71,75,76,77,79,81]).
pickPattern(2, [5,7,10,12,13,14,15,18,21,24,25,26,27,29,34,35,36,40,42,46,47,48,55,56,57,58,61,64,67,68,69,70,72,75,77]).
pickPattern(3, [2,4,6,7,10,15,16,17,19,21,25,27,29,30,31,34,40,42,48,51,52,53,55,57,61,63,65,66,67,72,75,76,78,80]).

/*
	Convert a Flat Sudoku Problem between flattened and unflattened list of list.
*/
convertFlatToLL(A, B):- A =
							[A1,A2,A3,A4,A5,A6,A7,A8,A9,
							A10,A11,A12,A13,A14,A15,A16,A17,A18,
							A19,A20,A21,A22,A23,A24,A25,A26,A27,
							A28,A29,A30,A31,A32,A33,A34,A35,A36,
							A37,A38,A39,A40,A41,A42,A43,A44,A45,
							A46,A47,A48,A49,A50,A51,A52,A53,A54,
							A55,A56,A57,A58,A59,A60,A61,A62,A63,
							A64,A65,A66,A67,A68,A69,A70,A71,A72,
							A73,A74,A75,A76,A77,A78,A79,A80,A81],
						B =
							[[A1,A2,A3,A4,A5,A6,A7,A8,A9],
							[A10,A11,A12,A13,A14,A15,A16,A17,A18],
							[A19,A20,A21,A22,A23,A24,A25,A26,A27],
							[A28,A29,A30,A31,A32,A33,A34,A35,A36],
							[A37,A38,A39,A40,A41,A42,A43,A44,A45],
							[A46,A47,A48,A49,A50,A51,A52,A53,A54],
							[A55,A56,A57,A58,A59,A60,A61,A62,A63],
							[A64,A65,A66,A67,A68,A69,A70,A71,A72],
							[A73,A74,A75,A76,A77,A78,A79,A80,A81]].
				
/*
	Define the length of a list.
*/	
length_list(Length, List) :- length(List, Length).

/*
	Define blocks as 3x3 units that are all distinct.
*/
blocks([], [], []). 
blocks(	[A,B,C|Bs1], 
		[D,E,F|Bs2], 
		[G,H,I|Bs3]) :- all_distinct([A,B,C,D,E,F,G,H,I]), 
						blocks(Bs1, Bs2, Bs3).
				


