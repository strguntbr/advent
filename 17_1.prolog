inc(C0, C1) :- plus(C0, 1, C1).

willCubeBeActive(_, _, _, ACTIVE_NEIGHBOURS, _) :- ACTIVE_NEIGHBOURS =:= 3, !.
willCubeBeActive(X, Y, Z, ACTIVE_NEIGHBOURS, ALL_CUBES) :- member(active{x:X, y:Y, z:Z}, ALL_CUBES), !, ACTIVE_NEIGHBOURS >= 2, ACTIVE_NEIGHBOURS =< 3.

countActiveNeighbors([], _, _, _, 0) :- !.
countActiveNeighbors([active{x:X, y:Y, z:Z}|T], X, Y, Z, COUNT) :- !, countActiveNeighbors(T, X, Y, Z, COUNT).
countActiveNeighbors([active{x:Xn, y:Yn, z:Zn}|T], X, Y, Z, COUNT) :- 
  plus(X, Xd, Xn), between(-1, 1, Xd),
  plus(Y, Yd, Yn), between(-1, 1, Yd),
  plus(Z, Zd, Zn), between(-1, 1, Zd),
  !, countActiveNeighbors(T, X, Y, Z, COUNTn),
  inc(COUNTn, COUNT).
countActiveNeighbors([_|T], X, Y, Z, COUNT) :- countActiveNeighbors(T, X, Y, Z, COUNT).  

cubeActiveInNextCycle(X, Y, Z, PREV_CUBES) :-
  countActiveNeighbors(PREV_CUBES, X, Y, Z, ACTIVE_NEIGHBOURS),
  willCubeBeActive(X, Y, Z, ACTIVE_NEIGHBOURS, PREV_CUBES).
cubeActiveInNextCycle(active{x:X, y:Y, z:Z}, PREV_CUBES, Xmin, Xmax, Ymin, Ymax, Zmin, Zmax) :- 
  between(Xmin, Xmax, X),
  between(Ymin, Ymax, Y),
  between(Zmin, Zmax, Z),
  cubeActiveInNextCycle(X, Y, Z, PREV_CUBES).

nextCycle(PREV_CUBES, Xmin, Xmax, Ymin, Ymax, Zmin, Zmax, NEXT_CUBES) :-
  findall(CUBE, cubeActiveInNextCycle(CUBE, PREV_CUBES, Xmin, Xmax, Ymin, Ymax, Zmin, Zmax), NEXT_CUBES).

countInNCycles(0, PREV_CUBES, _, _, _, _, _, _, COUNT) :- length(PREV_CUBES, COUNT).
countInNCycles(I, PREV_CUBES, Xmin, Xmax, Ymin, Ymax, Zmin, Zmax, COUNT) :-
  inc(Xmin_n, Xmin), inc(Xmax, Xmax_n),
  inc(Ymin_n, Ymin), inc(Ymax, Ymax_n),
  inc(Zmin_n, Zmin), inc(Zmax, Zmax_n),
  nextCycle(PREV_CUBES, Xmin_n, Xmax_n, Ymin_n, Ymax_n, Zmin_n, Zmax_n, NEXT_CUBES),
  inc(In, I),
  countInNCycles(In, NEXT_CUBES, Xmin_n, Xmax_n, Ymin_n, Ymax_n, Zmin_n, Zmax_n, COUNT), !.

convertX(_, _, _, [], []).
convertX(X, Y, Z, [0|T], CUBES) :- inc(X, Xn), convertX(Xn, Y, Z, T, CUBES).
convertX(X, Y, Z, [1|T], [active{x:X, y:Y, z:Z}|CUBES]) :- inc(X, Xn), convertX(Xn, Y, Z, T, CUBES).
convertY(_, _, _, [], []).
convertY(X, Y, Z, [H|T], CUBES) :- convertX(X, Y, Z, H, CUBESx), inc(Y, Yn), convertY(X, Yn, Z, T, CUBESy), append(CUBESx, CUBESy, CUBES).
convertZ(_, _, _, [], []).
convertZ(X, Y, Z, [H|T], CUBES) :- convertY(X, Y, Z, H, CUBESy), inc(Z, Zn), convertZ(X, Y, Zn, T, CUBESz), append(CUBESy, CUBESz, CUBES).

initialSize([], 0, 0, 0, 0, 0, 0).
initialSize([active{x:X, y:Y, z:Z}|T], Xmin, Xmax, Ymin, Ymax, Zmin, Zmax) :-
  initialSize(T, Xmin_t, Xmax_t, Ymin_t, Ymax_t, Zmin_t, Zmax_t),
  max_member(Xmax, [X, Xmax_t]),
  min_member(Xmin, [X, Xmin_t]),
  max_member(Ymax, [Y, Ymax_t]),
  min_member(Ymin, [Y, Ymin_t]),
  max_member(Zmax, [Z, Zmax_t]),
  max_member(Zmin, [Z, Zmin_t]).

solve(FILE) :-
  loadData(SOURCE_ARRAY, FILE),
  convertY(0, 0, 0, SOURCE_ARRAY, CUBES),
  initialSize(CUBES, Xmin, Xmax, Ymin, Ymax, Zmin, Zmax),
  countInNCycles(6, CUBES, Xmin, Xmax, Ymin, Ymax, Zmin, Zmax, COUNT),
  write(COUNT).
solveTest :- ['lib/loadData.prolog'], solveTestDay(17).
solveTest(N) :- ['lib/loadData.prolog'], solveTestDay(17, N).
solve :- ['lib/loadData.prolog'], solveDay(17).

/* required for loadData */
data_line(SOURCES, LINE) :- string_chars(LINE, CHARS), chars_cubes(CHARS, SOURCES).
chars_cubes([], []).
chars_cubes([Hc|Tc], [Hs|Ts]) :- char_cube(Hc, Hs), chars_cubes(Tc, Ts).
char_cube('#', 1).
char_cube('.', 0).