increases([_], 0) :- !.
increases([F|[S|T]], I) :- F < S, !, increases([S|T], J), I is J+1.
increases([_|T], I) :- increases(T, I).

result(DATA, RESULT) :- increases(DATA, RESULT).

day(1). testResult(7). solve :- ['lib/solve.prolog'], printResult.

/* required for loadData */
data_line(DATA, LINE) :- number_string(DATA, LINE).
