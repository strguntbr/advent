day(24).

move(c{x: X, y: Y}, w, c{x: Xn, y: Y}) :- Xn is X - 1.
move(c{x: X, y: Y}, e, c{x: Xn, y: Y}) :- Xn is X + 1.
move(c{x: X, y: Y}, nw, c{x: X, y: Yn}) :- Yn is Y + 1.
move(c{x: X, y: Y}, se, c{x: X, y: Yn}) :- Yn is Y - 1.
move(c{x: X, y: Y}, ne, c{x: Xn, y: Yn}) :- Yn is Y + 1, Xn is X + 1.
move(c{x: X, y: Y}, sw, c{x: Xn, y: Yn}) :- Yn is Y - 1, Xn is X - 1.

normalize([], c{x: 0, y: 0}).
normalize([FirstDir|RestOfPath], Coordinate) :- normalize(RestOfPath, RestCoordinate), move(RestCoordinate, FirstDir, Coordinate).

flip(Path) :- black(Path), !, retractall(black(Path)).
flip(Path) :- assertz(black(Path)).

flipall([]).
flipall([Path|OtherPaths]) :- flip(Path), flipall(OtherPaths).

solve(File) :-
  reset,
  loadData(TilePaths, File), maplist(normalize, TilePaths, NormalizedPaths),
  flipall(NormalizedPaths), aggregate_all(count, black(_), Result),
  !, write(Result).
solveTest :- ['lib/loadData.prolog'], day(DAY), solveTestDay(DAY).
solveTest(N) :- ['lib/loadData.prolog'], day(DAY), solveTestDay(DAY, N).
solve :- ['lib/loadData.prolog'], day(DAY), solveDay(DAY).

reset :- retractall(black(_)).

/* required for loadData */
data_line(Directions, Line) :- string_chars(Line, Chars), chars_directions(Chars, Directions).

chars_directions([], []).
chars_directions(['e'|T], [e|Td]) :- chars_directions(T, Td).
chars_directions(['w'|T], [w|Td]) :- chars_directions(T, Td).
chars_directions(['s'|['e'|T]], [se|Td]) :- chars_directions(T, Td).
chars_directions(['s'|['w'|T]], [sw|Td]) :- chars_directions(T, Td).
chars_directions(['n'|['e'|T]], [ne|Td]) :- chars_directions(T, Td).
chars_directions(['n'|['w'|T]], [nw|Td]) :- chars_directions(T, Td).