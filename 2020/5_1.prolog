max(A, B, A) :- A >= B, !. max(_, B, B).
maxInList([H|[]], H) :- !.
maxInList([H|T], MAX) :- maxInList(T, T_MAX), max(H, T_MAX, MAX).

bin_val(VAL0, _, VAL0, 0). bin_val(_, VAL1, VAL1, 1).
binary_number([H|[]], NUMBER, VAL0, VAL1, 1) :- !, bin_val(VAL0, VAL1, H, NUMBER).
binary_number([H|T], NUMBER, VAL0, VAL1, C) :- T_C is C - 1, binary_number(T, T_NR, VAL0, VAL1, T_C), bin_val(VAL0, VAL1, H, H_VAL), NUMBER is T_NR * 2 + H_VAL.
row_nr(ROW, ROW_NR) :- binary_number(ROW, ROW_NR, 'F', 'B', 7).
col_nr(COL, COL_NR) :- binary_number(COL, COL_NR, 'L', 'R', 3).
boardingPass_seat(boardingPass{row: ROW, col: COL}, SEAT_ID) :- row_nr(ROW, ROW_NR), col_nr(COL, COL_NR), SEAT_ID is ROW_NR*8 + COL_NR. 

boardingPasses_seats([], []).
boardingPasses_seats([FIRST_PASS|OTHER_PASSES], [FIRST_ID|OTHER_IDS]) :-
  boardingPass_seat(FIRST_PASS, FIRST_ID),
  boardingPasses_seats(OTHER_PASSES, OTHER_IDS).

maxSeat(BOARDING_PASSES, MAX) :- boardingPasses_seats(BOARDING_PASSES, SEAT_IDS), maxInList(SEAT_IDS, MAX).

solve(FILE) :- ['lib/loadData.prolog'], loadData(BOARDING_PASSES, FILE), maxSeat(BOARDING_PASSES, MAX), write(MAX).
solve :- solve('input/5.data').

/* required for loadData */
data_line(boardingPass{row: ROW, col: COL}, LINE) :- 
  sub_string(LINE, 0, 7, 3, ROW_STR), string_chars(ROW_STR, ROW_R), reverse(ROW_R, ROW),  
  sub_string(LINE, 7, 3, 0, COL_STR), string_chars(COL_STR, COL_R), reverse(COL_R, COL).