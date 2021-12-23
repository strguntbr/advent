:- include('lib/solve.prolog'). day(11). testResult(1656).

neighbors(X, Y, Xn, Yn) :- 
  Xmin is X - 1, Xmax is X + 1, Ymin is Y - 1, Ymax is Y + 1,
  between(Xmin, Xmax, Xn), between(Ymin, Ymax, Yn),
  [X, Y] \= [Xn, Yn].

neighboringOctopus(X, Y, Xn, Yn) :- neighbors(X, Y, Xn, Yn), octopus(Xn, Yn, _).
flashingOctopus(X, Y) :- octopus(X, Y, E), E > 9.

steps(0, 0) :- !.
steps(C, FLASHES) :- Cn is C - 1, steps(Cn, FLASHESn), incrementAll(FLASHEScur), FLASHES is FLASHESn + FLASHEScur.

setOctopus(X, Y, E) :- retractall(octopus(X, Y, _)), assert(octopus(X, Y, E)), printOneOctopus(X, Y).

incrementAll(FLASHES) :-
  octopuses(OCTOPUSES),
  maplist(increment, OCTOPUSES, FLASH_LIST),
  sumlist(FLASH_LIST, FLASHES),
  resetFlashes.
increment([X, Y], FLASHES) :- octopus(X, Y, E), E == 9, !,
  setOctopus(X, Y, 10),
  incrementNeighbors(X, Y, FLASHESn), FLASHES is FLASHESn + 1.
increment([X, Y], 0) :- octopus(X, Y, E), En is E + 1, setOctopus(X, Y, En).
incrementNeighbors(X, Y, FLASHES) :- 
  findall([Xn, Yn], neighboringOctopus(X, Y, Xn, Yn), OCTOPUSES),
  maplist(increment, OCTOPUSES, FLASH_LIST),
  sumlist(FLASH_LIST, FLASHES).

resetFlashes :- flashingOctopus(X, Y), !, retractall(octopus(X, Y, _)), assert(octopus(X, Y, 0)), resetFlashes.
resetFlashes.

result(ENERGY_LEVEL_MATRIX, FLASHES) :-
  cursorPosition(POS),
  initOctopuses(ENERGY_LEVEL_MATRIX),
  steps(100, FLASHES),
  clearOctopuses,
  RIGHT is POS - 1, moveCursor(1, 'up'), moveCursor(RIGHT, 'right').

initOctopuses(ENERGY_LEVEL_MATRIX) :-
  retractall(octopus(_, _, _)), initOctopuses(ENERGY_LEVEL_MATRIX, 0),
  findall([X, Y], octopus(X, Y, _), OCTOPUSES), retractall(octopuses(_)), assert(octopuses(OCTOPUSES)),
  length(OCTOPUSES, OCTOPUS_COUNT), retractall(octopusCount(_)), assert(octopusCount(OCTOPUS_COUNT)),
  printOctopuses.
initOctopuses([], _).
initOctopuses([H|T], X) :- initOctopuses(H, X, 0), Xn is X + 1, initOctopuses(T, Xn).
initOctopuses([], _, _).
initOctopuses([H|T], X, Y) :- assert(octopus(X, Y, H)), Yn is Y + 1, initOctopuses(T, X, Yn).

/* required for loadData */
data_line(ENERGY_LEVELS, LINE) :- string_chars(LINE, TMP), maplist(atom_number, TMP, ENERGY_LEVELS).

/* output */
printOctopuses :- isAnsiXterm -> (
    writeln(""),
    aggregate_all(max(X), octopus(X, _, _), Xmax), aggregate_all(max(Y), octopus(Xmax, Y, _), Ymax),
    forall(between(0, Xmax, Xc), printOctopuses(Xc)), moveCursor(Xmax + 1, 'up'), moveCursor(Ymax + 1, 'left')
  ) ; true.
printOctopuses(X) :-
  aggregate_all(max(Y), octopus(_, Y, _), Ymax),
  forall(between(0, Ymax, Yc), printOctopus(X, Yc)), writeln("").
printOctopus(X, Y) :- octopus(X, Y, E), energy_string(E, E_STR), write(E_STR).
clearOctopuses :- isAnsiXterm -> (
    aggregate_all(max(X), octopus(X, _, _), Xmax), aggregate_all(max(Y), octopus(Xmax, Y, _), Ymax),
    forall(between(0, Xmax, _), clearOctopusesLine(Ymax)),
    moveCursor(Xmax, 'up'), moveCursor(Ymax, 'left'), moveCursor(1, 'up')
  ) ; true.
clearOctopusesLine(LEN) :- forall(between(0, LEN, _), write(" ")), writeln("").
printOneOctopus(X, Y) :- isAnsiXterm -> (
    octopus(X, Y, E), energy_string(E, E_STR),
    moveCursor(Y, 'right'), moveCursor(X, 'down'), 
    format('~w\033[1D', [E_STR]),
    moveCursor(Y, 'left'), moveCursor(X, 'up')
  ) ; true.
energy_string(E, S) :- (
  E > 9 -> S = "\033[1;37m0\033[0m"
  ; S = E
).