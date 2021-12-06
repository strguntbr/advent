increases([_], 0) :- !.
increases([F|[S|T]], I) :- F < S, !, increases([S|T], J), I is J+1.
increases([_|T], I) :- increases(T, I).

avg([_|[_]], []) :- !.
avg([Ai|[Bi|[Ci|Ti]]], [Ao|To]) :- Ao is Ai+Bi+Ci, avg([Bi|[Ci|Ti]], To).

result(DATA, RESULT) :- avg(DATA, AVG_DATA), increases(AVG_DATA, RESULT).

day(1). testResult(5). solve :- ['lib/solve.prolog'], printResult.

/* required for loadData */
data_line(DATA, LINE) :- number_string(DATA, LINE).
