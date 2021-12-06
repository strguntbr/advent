isFloor(SEATS, ROW, COL) :- nth0(ROW, SEATS, SEAT_ROW), nth0(COL, SEAT_ROW, '.').
isSeat(SEATS, ROW, COL, 0) :- nth0(ROW, SEATS, SEAT_ROW), nth0(COL, SEAT_ROW, 'L'), !.
isSeat(SEATS, ROW, COL, 1) :- nth0(ROW, SEATS, SEAT_ROW), nth0(COL, SEAT_ROW, '#'), !.

incIfSeatOccupied(_,     _,   _,   _,     _,     MAX_OCCUPIED, MAX_OCCUPIED,  MAX_OCCUPIED) :- !.
incIfSeatOccupied(SEATS, ROW, COL, D_ROW, D_COL, _,            PREV_OCCUPIED, OCCUPIED) :-
  NEXT_ROW is ROW+D_ROW, NEXT_COL is COL+D_COL,
  isSeat(SEATS, NEXT_ROW, NEXT_COL, 1), !, OCCUPIED is PREV_OCCUPIED+1.
incIfSeatOccupied(SEATS, ROW, COL, D_ROW, D_COL, _,            OCCUPIED,      OCCUPIED) :-
  NEXT_ROW is ROW+D_ROW, NEXT_COL is COL+D_COL,
  isSeat(SEATS, NEXT_ROW, NEXT_COL, 0), !.
incIfSeatOccupied(SEATS, ROW, COL, D_ROW, D_COL, MAX_OCCUPIED, OCCUPIED,      NEXT_OCCUPIED) :-
  NEXT_ROW is ROW+D_ROW, NEXT_COL is COL+D_COL,
  isFloor(SEATS, NEXT_ROW, NEXT_COL), !,
  incIfSeatOccupied(SEATS, NEXT_ROW, NEXT_COL, D_ROW, D_COL, MAX_OCCUPIED, OCCUPIED, NEXT_OCCUPIED).
incIfSeatOccupied(_, _, _, _, _, _,            OCCUPIED,      OCCUPIED).

countOccupiedSeatsAround(SEATS, ROW, COL, MAX_COUNT, COUNT) :-
  incIfSeatOccupied(SEATS, ROW, COL, -1, -1, MAX_COUNT, 0, O1),
  incIfSeatOccupied(SEATS, ROW, COL, -1, 0,  MAX_COUNT, O1, O2),
  incIfSeatOccupied(SEATS, ROW, COL, -1, 1,  MAX_COUNT, O2, O3),
  incIfSeatOccupied(SEATS, ROW, COL, 0,  -1, MAX_COUNT, O3, O4),
  incIfSeatOccupied(SEATS, ROW, COL, 0,  1,  MAX_COUNT, O4, O5),
  incIfSeatOccupied(SEATS, ROW, COL, 1,  -1, MAX_COUNT, O5, O6),
  incIfSeatOccupied(SEATS, ROW, COL, 1,  0,  MAX_COUNT, O6, O7),
  incIfSeatOccupied(SEATS, ROW, COL, 1,  1,  MAX_COUNT, O7, COUNT).

isOccupiedSeat(ALL_PREV_SEATS, ROW, COL) :- 
  isSeat(ALL_PREV_SEATS, ROW, COL, 1), !,
  countOccupiedSeatsAround(ALL_PREV_SEATS, ROW, COL, 5, COUNT),
  COUNT < 5.
isOccupiedSeat(ALL_PREV_SEATS, ROW, COL) :- 
  isSeat(ALL_PREV_SEATS, ROW, COL, 0), !,
  countOccupiedSeatsAround(ALL_PREV_SEATS, ROW, COL, 1, COUNT),
  COUNT =:= 0.
seatAtPos(ALL_PREV_SEATS, ROW, COL, '#') :- isOccupiedSeat(ALL_PREV_SEATS, ROW, COL), !.
seatAtPos(ALL_PREV_SEATS, ROW, COL, 'L') :- isSeat(ALL_PREV_SEATS, ROW, COL, _), !, not(isOccupiedSeat(ALL_PREV_SEATS, ROW, COL)).
seatAtPos(ALL_PREV_SEATS, ROW, COL, '.') :- nth0(ROW, ALL_PREV_SEATS, SEATS), nth0(COL, SEATS, _), !.

rowOccupancy(ALL_PREV_SEATS, ROW, COL, []) :- nth0(ROW, ALL_PREV_SEATS, SEATS), not(nth0(COL, SEATS, _)), !.
rowOccupancy(ALL_PREV_SEATS, ROW, COL, [NEW_SEAT|OTHER_NEW_SEATS]) :-
  seatAtPos(ALL_PREV_SEATS, ROW, COL, NEW_SEAT),
  NEXT_COL is COL+1,
  rowOccupancy(ALL_PREV_SEATS, ROW, NEXT_COL, OTHER_NEW_SEATS).
occupancy(ALL_PREV_SEATS, ROW, []) :- not(nth0(ROW, ALL_PREV_SEATS, _)), !.
occupancy(ALL_PREV_SEATS, ROW, [NEW_ROW|OTHER_ROWS]) :-
  rowOccupancy(ALL_PREV_SEATS, ROW, 0, NEW_ROW),
  NEXT_ROW is ROW+1,
  occupancy(ALL_PREV_SEATS, NEXT_ROW, OTHER_ROWS).
occupancy(PREV_SEATS, SEATS) :- occupancy(PREV_SEATS, 0, SEATS).

finalOccupancy(PREV_SEATS, PREV_SEATS) :-
  occupancy(PREV_SEATS, PREV_SEATS), !.
finalOccupancy(PREV_SEATS, FINAL_SEATS) :-
  occupancy(PREV_SEATS, NEXT_SEATS),
  finalOccupancy(NEXT_SEATS, FINAL_SEATS).

countOccupied([], 0).
countOccupied(['#'|OTHER_SEATS], COUNT) :- !,
  countOccupied(OTHER_SEATS, OTHER_COUNT),
  COUNT is OTHER_COUNT+1.
countOccupied([_|OTHER_SEATS], COUNT) :- countOccupied(OTHER_SEATS, COUNT).
countAllOccupied([], 0).
countAllOccupied([H|T], COUNT) :-
  countOccupied(H, COUNT_ROW),
  countAllOccupied(T, COUNT_OTHER),
  COUNT is COUNT_ROW + COUNT_OTHER.

solve(FILE) :-
  ['lib/loadData.prolog'], 
  loadData(SEATS, FILE),
  finalOccupancy(SEATS, FINAL_SEATS),
  countAllOccupied(FINAL_SEATS, COUNT),
  write(COUNT).
solve :- solve('input/11.data').

/* required for loadData */
data_line(ROW, LINE) :- string_chars(LINE, ROW).