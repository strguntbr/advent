day(1). testResult(5). solve :- ['lib/solve.prolog'], printResult.

result(Report, Increases) :- aggregate_all(count, doesIncrease(Report), Increases).

doesIncrease(Report) :- append(_, [First,_,_,Forth|_], Report), Forth > First.

/* required for loadData */
data_line(Data, Line) :- number_string(Data, Line).
