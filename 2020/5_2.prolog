bin_val(VAL0, _, VAL0, 0). bin_val(_, VAL1, VAL1, 1).
binary_number([H|[]], NUMBER, VAL0, VAL1, 1) :- !, bin_val(VAL0, VAL1, H, NUMBER).
binary_number([H|T], NUMBER, VAL0, VAL1, C) :- T_C is C - 1, binary_number(T, T_NR, VAL0, VAL1, T_C), bin_val(VAL0, VAL1, H, H_VAL), NUMBER is T_NR * 2 + H_VAL.
row_nr(ROW, ROW_NR) :- binary_number(ROW, ROW_NR, 'F', 'B', 7).
col_nr(COL, COL_NR) :- binary_number(COL, COL_NR, 'L', 'R', 3).
boardingPass_seat(boardingPass{row: ROW, col: COL}, SEAT_ID) :- row_nr(ROW, ROW_NR), col_nr(COL, COL_NR), SEAT_ID =:= ROW_NR*8 + COL_NR. 

possibleSeat(SEAT) :- between(0, 1023, SEAT).

mySeat(BOARDING_PASSES, MY_SEAT) :- 
  possibleSeat(MY_SEAT), boardingPass_seat(MY_PASS, MY_SEAT), not(member(MY_PASS, BOARDING_PASSES)),
  PREV_SEAT is MY_SEAT - 1, boardingPass_seat(PREV_PASS, PREV_SEAT), member(PREV_PASS, BOARDING_PASSES),
  NEXT_SEAT is MY_SEAT + 1, boardingPass_seat(NEXT_PASS, NEXT_SEAT), member(NEXT_PASS, BOARDING_PASSES).

solve(FILE) :- ['lib/loadData.prolog'], loadData(BOARDING_PASSES, FILE), mySeat(BOARDING_PASSES, MY_SEAT), write(MY_SEAT).
solve :- solve('input/5.data').

/* required for loadData */
data_line(boardingPass{row: ROW, col: COL}, LINE) :- 
  sub_string(LINE, 0, 7, 3, ROW_STR), string_chars(ROW_STR, ROW_R), reverse(ROW_R, ROW),  
  sub_string(LINE, 7, 3, 0, COL_STR), string_chars(COL_STR, COL_R), reverse(COL_R, COL).