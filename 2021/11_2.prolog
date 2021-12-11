neighbors(X, Y, Xn, Yn) :- 
  Xmin is X - 1, Xmax is X + 1, Ymin is Y - 1, Ymax is Y + 1,
  between(Xmin, Xmax, Xn), between(Ymin, Ymax, Yn),
  [X, Y] \= [Xn, Yn].

neighboringOctopus(X, Y, Xn, Yn) :- neighbors(X, Y, Xn, Yn), octopus(Xn, Yn, _).
flashingOctopus(X, Y) :- octopus(X, Y, E), E > 9.

steps(STEPS) :- incrementAll(FLASHES), !, nextStep(FLASHES, STEPS).
nextStep(FLASHES, 1) :- octopusCount(FLASHES), !.
nextStep(_, STEPS) :- steps(STEPSn), STEPS is STEPSn + 1.

incrementAll(FLASHES) :-
  octopuses(OCTOPUSES),
  maplist(increment, OCTOPUSES, FLASH_LIST),
  sumlist(FLASH_LIST, FLASHES),
  resetFlashes.
increment([X, Y], FLASHES) :- octopus(X, Y, E), E == 9, !,
  retractall(octopus(X, Y, _)), assert(octopus(X, Y, 10)),
  incrementNeighbors(X, Y, FLASHESn), FLASHES is FLASHESn + 1.
increment([X, Y], 0) :- octopus(X, Y, E), En is E + 1, retractall(octopus(X, Y, _)), assert(octopus(X, Y, En)).
incrementNeighbors(X, Y, FLASHES) :- 
  findall([Xn, Yn], neighboringOctopus(X, Y, Xn, Yn), OCTOPUSES),
  maplist(increment, OCTOPUSES, FLASH_LIST),
  sumlist(FLASH_LIST, FLASHES).

resetFlashes :- flashingOctopus(X, Y), !, retractall(octopus(X, Y, _)), assert(octopus(X, Y, 0)), resetFlashes.
resetFlashes.

result(ENERGY_LEVEL_MATRIX, STEPS) :-
  initOctopuses(ENERGY_LEVEL_MATRIX),
  steps(STEPS).

day(11). testResult(195). solve :- ['lib/solve.prolog'], printResult.

initOctopuses(ENERGY_LEVEL_MATRIX) :-
  retractall(octopus(_, _, _)), initOctopuses(ENERGY_LEVEL_MATRIX, 0),
  findall([X, Y], octopus(X, Y, _), OCTOPUSES), retractall(octopuses(_)), assert(octopuses(OCTOPUSES)),
  length(OCTOPUSES, OCTOPUS_COUNT), retractall(octopusCount(_)), assert(octopusCount(OCTOPUS_COUNT)).
initOctopuses([], _).
initOctopuses([H|T], X) :- initOctopuses(H, X, 0), Xn is X + 1, initOctopuses(T, Xn).
initOctopuses([], _, _).
initOctopuses([H|T], X, Y) :- assert(octopus(X, Y, H)), Yn is Y + 1, initOctopuses(T, X, Yn).

/* required for loadData */
data_line(ENERGY_LEVELS, LINE) :- string_chars(LINE, TMP), maplist(atom_number, TMP, ENERGY_LEVELS).
