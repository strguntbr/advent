validTime(TIME, BUS_LINE, 0) :- !, TIME mod BUS_LINE =:= 0.
validTime(TIME, BUS_LINE, OFFSET) :- TIME mod BUS_LINE =:= BUS_LINE-OFFSET.

combineDepartures(dep{line: L1, after: O1}, dep{line: L2, after: O2}, COMBINED) :-
  L1 < L2, 
  !, combineDepartures(dep{line: L2, after: O2}, dep{line: L1, after: O1}, COMBINED).
combineDepartures(dep{line: L1, after: O1}, dep{line: L2, after: O2}, dep{line: Lc, after: Oc}) :-
  between(1, inf, I), TIME is I*L1-O1,
  validTime(TIME, L2, O2),
  !, Lc is L1*L2, Oc is Lc-TIME.

combineDepartures([DEP], DEP) :- !.
combineDepartures([H|T], DEP) :- combineDepartures(T, DEPt), combineDepartures(H, DEPt, DEP).

busLines_departures([], _, []).
busLines_departures(['x'|T], OFFSET, Td) :- !, NEXT_OFFSET is OFFSET+1, busLines_departures(T, NEXT_OFFSET, Td).
busLines_departures([BUS_LINE|T], OFFSET, [dep{line: BUS_LINE, after: OFFSET}|Td]) :- 
  NEXT_OFFSET is OFFSET+1,
  busLines_departures(T, NEXT_OFFSET, Td).
busLines_departures(BUSLINES, DEPARTURES) :- busLines_departures(BUSLINES, 0, DEPARTURES).

normalizeOffsets([], []).
normalizeOffsets([dep{line: BUS_LINE, after: OFFSET}|T], [dep{line: BUS_LINE, after: OFFSETn}|Tn]) :-
  OFFSETn is OFFSET mod BUS_LINE,
  normalizeOffsets(T, Tn).

solveBusLines(BUSLINES, RESULT) :-
  busLines_departures(BUSLINES, DEPARTURES),
  normalizeOffsets(DEPARTURES, NORMALIZED_DEPARTURES),
  combineDepartures(NORMALIZED_DEPARTURES, dep{line:COMBINED_LINE, after: COMBINED_OFFSET}),
  !, RESULT is COMBINED_LINE-COMBINED_OFFSET.

solve(FILE) :-
  ['lib/loadData.prolog'], 
  loadData([_,BUSLINES], FILE),
  solveBusLines(BUSLINES, RESULT),
  write(RESULT).
solve :- solve('input/13.data').

/* required for loadData */
data_line(BUSLINES, LINE) :- split_string(LINE, ",", "", SPLIT), strings_busLines(SPLIT, BUSLINES).
strings_busLines([], []).
strings_busLines(["x"|T], ['x'|Tb]) :- strings_busLines(T, Tb).
strings_busLines([H|T], [Hb|Tb]) :- number_string(Hb, H), strings_busLines(T, Tb).