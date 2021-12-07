grow(FISHES, 0, FISHES) :- !.
grow(FISHES, C, [AGE1, AGE2, AGE3, AGE4, AGE5, AGE6, AGE6n, AGE8, AGE0]) :-
  Cn is C - 1, grow(FISHES, Cn, [AGE0, AGE1, AGE2, AGE3, AGE4, AGE5, AGE6, AGE7, AGE8]),
  AGE6n is AGE7 + AGE0.

sum([], 0).
sum([H|T], S) :- sum(T, Sn), S is H + Sn.

result([FISHES], COUNT) :- grow(FISHES, 80, RESULT), sum(RESULT, COUNT).

day(6). testResult(5934). solve :- ['lib/solve.prolog'], printResult.

/* required for loadData */
data_line([AGE0, AGE1, AGE2, AGE3, AGE4, AGE5, AGE6, AGE7, AGE8], LINE) :-
  split_string(LINE, ",", "", AGES),
  count(AGES, "0", AGE0), count(AGES, "1", AGE1), count(AGES, "2", AGE2),
  count(AGES, "3", AGE3), count(AGES, "4", AGE4), count(AGES, "5", AGE5),
  count(AGES, "6", AGE6), count(AGES, "7", AGE7), count(AGES, "8", AGE8).

count([], _, 0).
count([X|T], X, C) :- !, count(T, X, Cn), C is Cn + 1.
count([_|T], X, C) :- count(T, X, C).
