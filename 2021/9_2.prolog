:- include('lib/solve.prolog'). day(9). testResult(1134).

adjacentNumbers(A, Aadj) :- Aadj is A + 1.
adjacentNumbers(A, Aadj) :- Aadj is A - 1.

adjacentLocations(X, Y, X, Yadj) :- adjacentNumbers(Y, Yadj), height(X, Yadj, _).
adjacentLocations(X, Y, Xadj, Y) :- adjacentNumbers(X, Xadj), height(Xadj, Y, _).

higher(X, Y, HEIGHT) :- height(X, Y, THIS_HEIGHT), THIS_HEIGHT > HEIGHT.

lowPoint(X, Y, HEIGHT) :-
  height(X, Y, HEIGHT),
  forall(adjacentLocations(X, Y, Xadj, Yadj), higher(Xadj, Yadj, HEIGHT)).

calcBasin(Xbasin, Ybasin, Hcur) :-
  height(X, Y, H), H >= Hcur, H < 9,
  not(inBasin(Xbasin, Ybasin, X, Y)),
  adjacentLocations(X, Y, Xadj, Yadj),
  inBasin(Xbasin, Ybasin, Xadj, Yadj),
  !, assert(inBasin(Xbasin, Ybasin, X, Y)),
  calcBasin(Xbasin, Ybasin, Hcur).
calcBasin(_, _, _).

calcBasins(DONE) :-
  lowPoint(X, Y, H),
  not(member([X,Y], DONE)),
  calcBasin(X,Y, H),
  !, calcBasins([[X,Y]|DONE]).
calcBasins(_).

basinSize(Xbasin, Ybasin, SIZE) :- lowPoint(Xbasin, Ybasin, _), aggregate_all(count, inBasin(Xbasin, Ybasin, _, _), SIZE).
basinLarger(Xbasin, Ybasin, MIN_SIZE) :- lowPoint(Xbasin, Ybasin, _), basinSize(Xbasin, Ybasin, SIZE), SIZE > MIN_SIZE.

topNLargestBasin(Xbasin, Ybasin, N) :-
  basinSize(Xbasin, Ybasin, S),
  aggregate_all(count, basinLarger(_, _, S), LARGER_BASINS),
  LARGER_BASINS < N.

sizeProduct([], 1).
sizeProduct([[Hx,Hy]|T], P) :- basinSize(Hx, Hy, S), sizeProduct(T, Pn), P is S*Pn.

result(HEIGHTMAP, RESULT) :- initFacts(HEIGHTMAP), calcBasins([]),
  findall([X,Y], topNLargestBasin(X, Y, 3), TOP_BASINS), sizeProduct(TOP_BASINS, RESULT).

initFacts(HEIGHTMAP) :- retractall(height(_,_,_)), retractall(inBasin(_, _, _, _)), assert(inBasin(X, Y, X, Y)), initFacts(HEIGHTMAP, 0).
initFacts([], _).
initFacts([FIRST_LINE|OTHER_LINES], X) :- initFacts(FIRST_LINE, X, 0), X_OTHER is X + 1, initFacts(OTHER_LINES, X_OTHER).
initFacts([], _, _).
initFacts([FIRST_HEIGHT|OTHER_HEIGHTS], X, Y) :- assert(height(X, Y, FIRST_HEIGHT)), Y_OTHER is Y + 1, initFacts(OTHER_HEIGHTS, X, Y_OTHER).

/* required for loadData */
data_line(HEIGHTS, LINE) :- string_chars(LINE, HEIGHT_CHARS), maplist(atom_number, HEIGHT_CHARS, HEIGHTS).
