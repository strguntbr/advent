inc(C0, C1) :- plus(C0, 1, C1).

willCubeBeActive(_, _, _, _, ACTIVE_NEIGHBOURS, _) :- ACTIVE_NEIGHBOURS =:= 3, !.
willCubeBeActive(X, Y, Z, W, ACTIVE_NEIGHBOURS, ALL_CUBES) :- member(active{x:X, y:Y, z:Z, w:W}, ALL_CUBES), !, ACTIVE_NEIGHBOURS >= 2, ACTIVE_NEIGHBOURS =< 3.

countActiveNeighbors([], _, _, _, _, 0) :- !.
countActiveNeighbors([active{x:X, y:Y, z:Z, w:W}|T], X, Y, Z, W, COUNT) :- !, countActiveNeighbors(T, X, Y, Z, W, COUNT).
countActiveNeighbors([active{x:Xn, y:Yn, z:Zn, w:Wn}|T], X, Y, Z, W, COUNT) :- 
  plus(X, Xd, Xn), between(-1, 1, Xd),
  plus(Y, Yd, Yn), between(-1, 1, Yd),
  plus(Z, Zd, Zn), between(-1, 1, Zd),
  plus(W, Wd, Wn), between(-1, 1, Wd),
  !, countActiveNeighbors(T, X, Y, Z, W, COUNTn),
  inc(COUNTn, COUNT).
countActiveNeighbors([_|T], X, Y, Z, W, COUNT) :- countActiveNeighbors(T, X, Y, Z, W, COUNT).  

cubeActiveInNextCycle(X, Y, Z, W, PREV_CUBES) :-
  countActiveNeighbors(PREV_CUBES, X, Y, Z, W, ACTIVE_NEIGHBOURS),
  willCubeBeActive(X, Y, Z, W, ACTIVE_NEIGHBOURS, PREV_CUBES).
cubeActiveInNextCycle(active{x:X, y:Y, z:Z, w:W}, PREV_CUBES, Xmin, Xmax, Ymin, Ymax, Zmin, Zmax, Wmin, Wmax) :- 
  between(Xmin, Xmax, X),
  between(Ymin, Ymax, Y),
  between(Zmin, Zmax, Z),
  between(Wmin, Wmax, W),
  cubeActiveInNextCycle(X, Y, Z, W, PREV_CUBES).

nextCycle(PREV_CUBES, Xmin, Xmax, Ymin, Ymax, Zmin, Zmax, Wmin, Wmax, NEXT_CUBES) :-
  findall(CUBE, cubeActiveInNextCycle(CUBE, PREV_CUBES, Xmin, Xmax, Ymin, Ymax, Zmin, Zmax, Wmin, Wmax), NEXT_CUBES).

countInNCycles(0, PREV_CUBES, _, _, _, _, _, _, _, _, COUNT) :- length(PREV_CUBES, COUNT).
countInNCycles(I, PREV_CUBES, Xmin, Xmax, Ymin, Ymax, Zmin, Zmax, Wmin, Wmax, COUNT) :-
  inc(Xmin_n, Xmin), inc(Xmax, Xmax_n),
  inc(Ymin_n, Ymin), inc(Ymax, Ymax_n),
  inc(Zmin_n, Zmin), inc(Zmax, Zmax_n),
  inc(Wmin_n, Wmin), inc(Wmax, Wmax_n),
  nextCycle(PREV_CUBES, Xmin_n, Xmax_n, Ymin_n, Ymax_n, Zmin_n, Zmax_n, Wmin_n, Wmax_n, NEXT_CUBES),
  inc(In, I),
  countInNCycles(In, NEXT_CUBES, Xmin_n, Xmax_n, Ymin_n, Ymax_n, Zmin_n, Zmax_n, Wmin_n, Wmax_n, COUNT), !.

convertX(_, _, _, _, [], []).
convertX(X, Y, Z, W, [0|T], CUBES) :- inc(X, Xn), convertX(Xn, Y, Z, W, T, CUBES).
convertX(X, Y, Z, W, [1|T], [active{x:X, y:Y, z:Z, w:W}|CUBES]) :- inc(X, Xn), convertX(Xn, Y, Z, W, T, CUBES).
convertY(_, _, _, _, [], []).
convertY(X, Y, Z, W, [H|T], CUBES) :- convertX(X, Y, Z, W, H, CUBESx), inc(Y, Yn), convertY(X, Yn, Z, W, T, CUBESy), append(CUBESx, CUBESy, CUBES).
convertZ(_, _, _, _, [], []).
convertZ(X, Y, Z, W, [H|T], CUBES) :- convertY(X, Y, Z, W, H, CUBESy), inc(Z, Zn), convertZ(X, Y, Zn, W, T, CUBESz), append(CUBESy, CUBESz, CUBES).
convertW(_, _, _, _, [], []).
convertW(X, Y, Z, W, [H|T], CUBES) :- convertZ(X, Y, Z, W, H, CUBESz), inc(W, Wn), convertZ(X, Y, Z, Wn, T, CUBESw), append(CUBESz, CUBESw, CUBES).

initialSize([], 0, 0, 0, 0, 0, 0, 0, 0).
initialSize([active{x:X, y:Y, z:Z, w:W}|T], Xmin, Xmax, Ymin, Ymax, Zmin, Zmax, Wmin, Wmax) :-
  initialSize(T, Xmin_t, Xmax_t, Ymin_t, Ymax_t, Zmin_t, Zmax_t, Wmin_t, Wmax_t),
  max_member(Xmax, [X, Xmax_t]),
  min_member(Xmin, [X, Xmin_t]),
  max_member(Ymax, [Y, Ymax_t]),
  min_member(Ymin, [Y, Ymin_t]),
  max_member(Zmax, [Z, Zmax_t]),
  max_member(Zmin, [Z, Zmin_t]),
  max_member(Wmax, [W, Wmax_t]),
  max_member(Wmin, [W, Wmin_t]).

solve(FILE) :-
  loadData(SOURCE_ARRAY, FILE),
  convertY(0, 0, 0, 0, SOURCE_ARRAY, CUBES),
  initialSize(CUBES, Xmin, Xmax, Ymin, Ymax, Zmin, Zmax, Wmin, Wmax),
  countInNCycles(6, CUBES, Xmin, Xmax, Ymin, Ymax, Zmin, Zmax, Wmin, Wmax, COUNT),
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