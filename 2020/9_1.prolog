numberValid(PREAMBLE, NUMBER) :- member(X, PREAMBLE), member(Y, PREAMBLE), X < Y, NUMBER =:= X + Y.
findInvalid(PREAMBLE, [FIRST_NUMBER|_], FIRST_NUMBER) :- not(numberValid(PREAMBLE, FIRST_NUMBER)), !.
findInvalid([_|PREAMBLE_TAIL], [FIRST_NUMBER|OTHER_NUMBERS], INVALID) :-
  append(PREAMBLE_TAIL, [FIRST_NUMBER], NEXT_PREAMBLE), findInvalid(NEXT_PREAMBLE, OTHER_NUMBERS, INVALID).

split_list(LIST, 0, [], LIST).
split_list([LIST_H|LIST_T], L1_LENGTH, [LIST_H|LIST1_T], LIST2) :-
  length(LIST_T, L_T), between(0, L_T, NEXT_L1_LENGTH), L is L_T + 1, between(0, L, L1_LENGTH), length(LIST1_T, NEXT_L1_LENGTH),
  L1_LENGTH =:= NEXT_L1_LENGTH + 1,
  split_list(LIST_T, NEXT_L1_LENGTH, LIST1_T, LIST2).

solve(FILE, PREAMBLE_LENGTH) :- ['lib/loadData.prolog'], loadData(NUMBERS, FILE), split_list(NUMBERS, PREAMBLE_LENGTH, PREAMBLE, CODE), findInvalid(PREAMBLE, CODE, INVALID), write(INVALID).
solve :- solve('input/9.data', 25).

/* required for loadData */
data_line(NUMBER, LINE) :- number_string(NUMBER, LINE).