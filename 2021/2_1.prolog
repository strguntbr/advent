day(2). testResult(150). solve :- ['lib/solve.prolog'], printResult.

result(Course, Result) :- pos(Course, [Horizontal, Depth]), Result is Horizontal*Depth.

pos([], [0, 0]).
pos([["forward", Units]|T], [Horizontal + Units, Depth]) :- pos(T, [Horizontal, Depth]).
pos([["up", Units]|T], [Horizontal, Depth - Units]) :- pos(T, [Horizontal, Depth]).
pos([["down", Units]|T], [Horizontal, Depth + Units]) :- pos(T, [Horizontal, Depth]).

/* required for loadData */
data_line([Direction, Units], Line) :- split_string(Line, " ", "", [Direction, UnitsStr]), number_string(Units, UnitsStr).
