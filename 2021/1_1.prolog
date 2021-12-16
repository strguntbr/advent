day(1). testResult(7). solve :- ['lib/solve.prolog'], printResult.

result(Report, Increases) :- aggregate_all(count, (append(_, [First,Second|_], Report), Second > First), Increases).

/* required for loadData */
data_line(Data, Line) :- number_string(Data, Line).
