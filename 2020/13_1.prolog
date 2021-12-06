nextDeparture(TIME, BUSLINE, NEXT) :- NEXT is BUSLINE - (TIME mod BUSLINE).
nextBus(TIME, [H|T], NEXT_BUS, DEPARTS_IN) :-
  nextBus(TIME, T, NEXT_BUS, DEPARTS_IN),
  nextDeparture(TIME, H, NEXT_DEPARTURE),
  DEPARTS_IN =< NEXT_DEPARTURE, !.
nextBus(TIME, [NEXT_BUS|_], NEXT_BUS, DEPARTS_IN) :- nextDeparture(TIME, NEXT_BUS, DEPARTS_IN).


solve(FILE) :-
  ['lib/loadData.prolog'], 
  loadData([TIME,BUSLINES], FILE),
  nextBus(TIME, BUSLINES, NEXT_BUS, DEPARTS_IN),
  RESULT is NEXT_BUS * DEPARTS_IN,
  write(RESULT).
solve :- solve('input/13.data').

/* required for loadData */
data_line(BUSLINES, LINE) :- split_string(LINE, ",", "", SPLIT), strings_busLines(SPLIT, BUSLINES).
strings_busLines([], []).
strings_busLines(["x"|T], Tb) :- strings_busLines(T, Tb).
strings_busLines([H|T], [Hb|Tb]) :- number_string(Hb, H), strings_busLines(T, Tb).
