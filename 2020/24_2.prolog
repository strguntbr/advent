day(24).

move(c{x: X, y: Y}, w, c{x: Xn, y: Y}) :- plus(Xn, 1, X).
move(c{x: X, y: Y}, e, c{x: Xn, y: Y}) :- plus(X, 1, Xn).
move(c{x: X, y: Y}, nw, c{x: X, y: Yn}) :- plus(Y, 1, Yn).
move(c{x: X, y: Y}, se, c{x: X, y: Yn}) :- plus(Yn, 1, Y).
move(c{x: X, y: Y}, ne, c{x: Xn, y: Yn}) :- plus(Y, 1, Yn), plus(X, 1, Xn).
move(c{x: X, y: Y}, sw, c{x: Xn, y: Yn}) :- plus(Yn, 1, Y), plus(Xn, 1, X).

normalize([], c{x: 0, y: 0}).
normalize([FirstDir|RestOfPath], Coordinate) :- normalize(RestOfPath, RestCoordinate), move(RestCoordinate, FirstDir, Coordinate).

flip(Path) :- black(0, Path), !, retractall(black(0, Path)).
flip(Path) :- assertz(black(0, Path)).

assertBlack(Round, Tile) :- black(Round, Tile), !.
assertBlack(Round, Tile) :- assertz(black(Round, Tile)).

prevBlack(Round, Tile) :- PrevRound is Round-1, black(PrevRound, Tile).

neighbor(Tile, Neighbor) :- move(Tile, _, Neighbor).
blackNeighbor(Round, Tile, Neighbor) :- neighbor(Tile, Neighbor), black(Round, Neighbor).

findNeighbors(Tile, Neighbors) :- findall(Neighbor, neighbor(Tile, Neighbor), Neighbors).
countBlackNeighbors(Round, Tile, BlackNeighborCount) :-  aggregate_all(count, blackNeighbor(Round, Tile, _), BlackNeighborCount).

updateTile(Round, Tile, BlackNeighborCount) :- prevBlack(Round, Tile), between(1, 2, BlackNeighborCount), !, assertBlack(Round, Tile).
updateTile(Round, Tile, BlackNeighborCount) :- BlackNeighborCount = 2, !, assertBlack(Round, Tile).
updateTile(_, _, _).

updateTile(Round, Tile) :- PrevRound is Round - 1, countBlackNeighbors(PrevRound, Tile, BlackNeighborCount), updateTile(Round, Tile, BlackNeighborCount).

updateNeighbors(_, []) :- !.
updateNeighbors(Round, [Tile|Rest]) :- updateTile(Round, Tile), updateNeighbors(Round, Rest).

calcNewRound(_, []).
calcNewRound(Round, [Tile|Rest]) :-
  updateTile(Round, Tile),
  findNeighbors(Tile, Neighbors),  updateNeighbors(Round, Neighbors),
  calcNewRound(Round, Rest).

calcNewRound(Round) :- findall(BlackTile, prevBlack(Round, BlackTile), BlackPrevRound), calcNewRound(Round, BlackPrevRound).

simulate(Rounds, Rounds) :- !, calcNewRound(Rounds).
simulate(CurRound, Rounds) :- CurRound < Rounds, calcNewRound(CurRound), NextRound is CurRound+1, simulate(NextRound, Rounds).
simulate(Rounds) :- simulate(1, Rounds).

solve(File) :-
  set_prolog_flag(stack_limit, 2_147_483_648), reset, Rounds = 100,
  loadData(TilePaths, File), maplist(normalize, TilePaths, NormalizedPaths), maplist(flip, NormalizedPaths),
  simulate(Rounds), aggregate_all(count, black(Rounds, _), Result),
  !, write(Result).
solveTest :- ['lib/loadData.prolog'], day(DAY), solveTestDay(DAY).
solveTest(N) :- ['lib/loadData.prolog'], day(DAY), solveTestDay(DAY, N).
solve :- ['lib/loadData.prolog'], day(DAY), solveDay(DAY).

reset :- retractall(black(_, _)).

/* required for loadData */
data_line(Directions, Line) :- string_chars(Line, Chars), chars_directions(Chars, Directions).

chars_directions([], []).
chars_directions(['e'|T], [e|Td]) :- chars_directions(T, Td).
chars_directions(['w'|T], [w|Td]) :- chars_directions(T, Td).
chars_directions(['s'|['e'|T]], [se|Td]) :- chars_directions(T, Td).
chars_directions(['s'|['w'|T]], [sw|Td]) :- chars_directions(T, Td).
chars_directions(['n'|['e'|T]], [ne|Td]) :- chars_directions(T, Td).
chars_directions(['n'|['w'|T]], [nw|Td]) :- chars_directions(T, Td).