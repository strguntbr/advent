pos([], 0, 0, 0).
pos([["forward",AMOUNT]|T], AIM, HORIZONTAL, DEPTH) :- pos(T, AIM, HORIZONTALn, DEPTHn), HORIZONTAL is HORIZONTALn + AMOUNT, DEPTH is DEPTHn + AMOUNT*AIM.
pos([["up",AMOUNT]|T], AIM, HORIZONTAL, DEPTH) :- pos(T, AIMn, HORIZONTAL, DEPTH), AIM is AIMn - AMOUNT.
pos([["down",AMOUNT]|T], AIM, HORIZONTAL, DEPTH) :- pos(T, AIMn, HORIZONTAL, DEPTH), AIM is AIMn + AMOUNT.

result(DATA, RESULT) :- reverse(DATA, REVDATA), pos(REVDATA, _, HORIZONTAL, DEPTH), RESULT is HORIZONTAL*DEPTH.

day(2). testResult(900). solve :- ['lib/solve.prolog'], printResult.

/* required for loadData */
data_line([DIR, AMOUNT], LINE) :-
    split_string(LINE, " ", "", [DIR, AMOUNT_STR]), number_string(AMOUNT, AMOUNT_STR).
