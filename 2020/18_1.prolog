eval(Number, Number) :- number(Number).
eval(calc{lhs: LHS, op: '+', rhs: RHS}, Result) :- eval(LHS, ResultL), eval(RHS, ResultR), Result is ResultL + ResultR.
eval(calc{lhs: LHS, op: '*', rhs: RHS}, Result) :- eval(LHS, ResultL), eval(RHS, ResultR), Result is ResultL * ResultR.

sumExpressions([], 0).
sumExpressions([H|T], Sum) :- eval(H, ResultH), sumExpressions(T, SumT), Sum is ResultH + SumT.

solve(File) :-
  loadData(Expressions, File),
  sumExpressions(Expressions, Result),
  write(Result).
solveTest :- ['lib/loadData.prolog'], solveTestDay(18).
solveTest(N) :- ['lib/loadData.prolog'], solveTestDay(18, N).
solve :- ['lib/loadData.prolog'], solveDay(18).

/* required for loadData */
data_line(Expression, Line) :- string_chars(Line, Chars), reverse(Chars, ReverseChars), expression(ReverseChars, Expression, []).

expression([' '|Input], Expression, Output) :- expression(Input, Expression, Output), !.
expression([Number|Output], NumberValue, Output) :- atom(Number), atom_number(Number, NumberValue), !.
expression([')'|Input], Expression, Output) :- expression(Input, Expression, ['('|Output]), !.
expression(Input, calc{lhs: LHS, rhs: RHS, op: Operation}, Output) :- 
  expression(Input, LHS, InputToOperation),
  operation(InputToOperation, Operation, OutputOfOperation),
  expression(OutputOfOperation, RHS, Output).

operation([' '|Input], Operation, Output) :- operation(Input, Operation, Output).
operation(['+'|Output], '+', Output).
operation(['*'|Output], '*', Output).