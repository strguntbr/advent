pos([], 0, 0).
pos([["forward",AMOUNT]|T], HORIZONTAL, DEPTH) :- pos(T, HORIZONTALn, DEPTH), HORIZONTAL is HORIZONTALn + AMOUNT.
pos([["up",AMOUNT]|T], HORIZONTAL, DEPTH) :- pos(T, HORIZONTAL, DEPTHn), DEPTH is DEPTHn - AMOUNT.
pos([["down",AMOUNT]|T], HORIZONTAL, DEPTH) :- pos(T, HORIZONTAL, DEPTHn), DEPTH is DEPTHn + AMOUNT.

result(DATA, RESULT) :- pos(DATA, HORIZONTAL, DEPTH), RESULT is HORIZONTAL*DEPTH.

day(2). testResult(150). solve :- ['lib/solve.prolog'], printResult.

/* required for loadData */
data_line([DIR, AMOUNT], LINE) :-
    split_string(LINE, " ", "", [DIR, AMOUNT_STR]), number_string(AMOUNT, AMOUNT_STR).
