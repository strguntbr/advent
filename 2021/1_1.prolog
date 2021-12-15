day(1). testResult(7). solve :- ['lib/solve.prolog'], printResult.

result(Report, Increases) :- aggregate_all(count, doesIncrease(Report), Increases).

doesIncrease(Report) :- append(_, [First,Second|_], Report), Second > First.

/* required for loadData */
data_line(Data, Line) :- number_string(Data, Line).
