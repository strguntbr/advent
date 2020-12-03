productForSum(INPUT, P, S) :- member(X, INPUT), member(Y, INPUT), X > Y, X+Y < S, member(Z, INPUT), Y > Z, S =:= X+Y+Z, !, P is X*Y*Z.

solve(FILE) :- ['lib/loadData.prolog'], loadData(DATA, FILE), productForSum(DATA, P, 2020), write(P).
solve :- solve('input/1.data').

/* required for loadData */
data_line(DATA, LINE) :- number_string(DATA, LINE).