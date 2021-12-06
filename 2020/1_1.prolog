productForSum(INPUT, P, S) :- member(X, INPUT), member(Y, INPUT), X > Y, S =:= X+Y, !, P is X*Y.

solve(FILE) :- ['lib/loadData.prolog'], loadData(DATA, FILE), productForSum(DATA, P, 2020), write(P).
solve :- solve('input/1.data').

/* required for loadData */
data_line(DATA, LINE) :- number_string(DATA, LINE).