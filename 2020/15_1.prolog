inc(I, In) :- plus(I, 1, In).

age([H|T], D) :- nth1(D, T, H), !.
age(_, 0).

nthNumber([RESULT|_], 0, RESULT) :- !.
nthNumber(NUMBERS, N, RESULT) :-
  inc(NEXT_N, N),
  age(NUMBERS, NEXT),
  nthNumber([NEXT|NUMBERS], NEXT_N, RESULT).

solve(STARTING_NUMBERS, N, RESULT) :-
  length(STARTING_NUMBERS, L_SO_FAR),
  plus(N_START, L_SO_FAR, N),
  reverse(STARTING_NUMBERS, REVERSE_NUMBERS),
  nthNumber(REVERSE_NUMBERS, N_START, RESULT).

solve(FILE) :-
  loadData([NUMBERS], FILE),
  solve(NUMBERS, 2020, RESULT),
  write(RESULT).
solveTest :- ['lib/loadData.prolog'], solveTestDay(15).
solveTest(N) :- ['lib/loadData.prolog'], solveTestDay(15, N).
solve :- ['lib/loadData.prolog'], solveDay(15).

/* required for loadData */
data_line(NUMBERS, LINE) :- split_string(LINE, ",", "", STRINGS), numbers_strings(NUMBERS, STRINGS).
numbers_strings([], []).
numbers_strings([Hn|Tn], [Hs|Ts]) :- number_string(Hn, Hs), numbers_strings(Tn, Ts).