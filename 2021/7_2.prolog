distance(POS, TARGET, DISTANCE) :- POS < TARGET, !, DISTANCE is TARGET - POS.
distance(POS, TARGET, DISTANCE) :- DISTANCE is POS - TARGET.
distance_fuel(D, F) :- F is (1 + D) * D / 2.
requiredFuel([], _, 0).
requiredFuel([FIRST_POS|OTHER_POSES], TARGET, FUEL) :-
  requiredFuel(OTHER_POSES, TARGET, OTHER_FUEL),
  distance(FIRST_POS, TARGET, FIRST_DISTANCE),
  distance_fuel(FIRST_DISTANCE, FIRST_FUEL),
  FUEL is FIRST_FUEL + OTHER_FUEL.

max([X], X).
max([H|T], Tm) :- max(T, Tm), H =< Tm, !.
max([H|_], H).

minFuel(POSITIONS, MAX_POS, MAX_POS, FUEL) :- !, requiredFuel(POSITIONS, MAX_POS, FUEL).
minFuel(POSITIONS, MAX_POS, TARGET, FUEL) :- TARGETn is TARGET + 1, requiredFuel(POSITIONS, TARGET, FUELc), minFuel(POSITIONS, MAX_POS, TARGETn, FUEL), FUEL < FUELc, !.
minFuel(POSITIONS, _, TARGET, FUEL) :- requiredFuel(POSITIONS, TARGET, FUEL).

result([POSITIONS], FUEL) :- max(POSITIONS, MAX_POS), minFuel(POSITIONS, MAX_POS, 0, FUEL).

day(7). testResult(168). solve :- ['lib/solve.prolog'], printResult.

/* required for loadData */
data_line(POSITIONS, LINE) :-  split_string(LINE, ",", "", POSITIONS_STR), numbers_strings(POSITIONS, POSITIONS_STR).

numbers_strings([], []).
numbers_strings([NH|NT], [SH|ST]) :- number_string(NH, SH), numbers_strings(NT, ST).
