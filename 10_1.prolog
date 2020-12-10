removeMinFromList([H], H, []).
removeMinFromList([H|T], H, T) :- min_list(T, MIN_T), H =< MIN_T, !.
removeMinFromList([H|T], MIN_T, [H|TO_WO_MIN]) :- removeMinFromList(T, MIN_T, TO_WO_MIN). 
connectAdapters([H], [H]).
connectAdapters(ADAPTERS, [MIN|[H|ORDERED_ADAPTERS]]) :-
  removeMinFromList(ADAPTERS, MIN, ADAPTERS_WO_MIN),
  connectAdapters(ADAPTERS_WO_MIN, [H|ORDERED_ADAPTERS]),
  H > MIN, MIN >= H-3.

countDistance([_], _, 0).
countDistance([H1|[H2|T]], DISTANCE, COUNT) :-
  DISTANCE =:= H2-H1, !,
  countDistance([H2|T], DISTANCE, NEXT_COUNT),
  COUNT is NEXT_COUNT + 1.
countDistance([_|T], DISTANCE, COUNT) :- countDistance(T, DISTANCE, COUNT).

solve(FILE) :-
  ['lib/loadData.prolog'], 
  loadData(ADAPTERS, FILE),
  connectAdapters([0|ADAPTERS], ORDERED_ADAPTERS),
  countDistance(ORDERED_ADAPTERS, 1, C1),
  countDistance(ORDERED_ADAPTERS, 3, C3),
  RESULT is C1*(C3+1),
  write(RESULT).
solve :- solve('input/10.data').

/* required for loadData */
data_line(ADAPTER, LINE) :- number_string(ADAPTER, LINE).