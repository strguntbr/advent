adjacentNumbers(A, Aadj) :- Aadj is A + 1.
adjacentNumbers(A, Aadj) :- Aadj is A - 1.

adjacentLocations(X, Y, X, Yadj) :- adjacentNumbers(Y, Yadj), height(X, Yadj, _).
adjacentLocations(X, Y, Xadj, Y) :- adjacentNumbers(X, Xadj), height(Xadj, Y, _).

higher(X, Y, HEIGHT) :- height(X, Y, THIS_HEIGHT), THIS_HEIGHT > HEIGHT.

lowPoint(X, Y, HEIGHT) :-
  height(X, Y, HEIGHT),
  forall(adjacentLocations(X, Y, Xadj, Yadj), higher(Xadj, Yadj, HEIGHT)).

lowPointRisk(X, Y, R) :- lowPoint(X, Y, HEIGHT), R is 1 + HEIGHT.

result(HEIGHTMAP, RISK_SUM) :- initFacts(HEIGHTMAP),
  aggregate_all(sum(RISK), lowPointRisk(_, _, RISK), RISK_SUM).

day(9). testResult(15). solve :- ['lib/solve.prolog'], printResult.

initFacts(HEIGHTMAP) :- retractall(height(_,_,_)), initFacts(HEIGHTMAP, 0).
initFacts([], _).
initFacts([FIRST_LINE|OTHER_LINES], X) :- initFacts(FIRST_LINE, X, 0), X_OTHER is X + 1, initFacts(OTHER_LINES, X_OTHER).
initFacts([], _, _).
initFacts([FIRST_HEIGHT|OTHER_HEIGHTS], X, Y) :- assert(height(X, Y, FIRST_HEIGHT)), Y_OTHER is Y + 1, initFacts(OTHER_HEIGHTS, X, Y_OTHER).

/* required for loadData */
data_line(HEIGHTS, LINE) :- string_chars(LINE, HEIGHT_CHARS), maplist(atom_number, HEIGHT_CHARS, HEIGHTS).
