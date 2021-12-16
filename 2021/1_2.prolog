day(1). testResult(5). solve :- ['lib/solve.prolog'], printResult.

result(Report, Increases) :- aggregate_all(count, (append(_, [First,_,_,Fourth|_], Report), Fourth > First), Increases).

/* required for loadData */
data_line(Data, Line) :- number_string(Data, Line).
