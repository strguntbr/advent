:- include('lib/solve.prolog'). day(2). testResult(900).

result(Course, Result) :- pos(Course, 0, [Horizontal, Depth]), Result is Horizontal * Depth.

pos([], _, [0, 0]).
pos([["forward", Units]|T], Velocity, [Horizontal + Units, Depth + Velocity * Units]) :- pos(T, Velocity, [Horizontal, Depth]).
pos([["up", Units]|T], Velocity, Position) :- pos(T, Velocity - Units, Position).
pos([["down", Units]|T], Velocity, Position) :- pos(T, Velocity + Units, Position).

/* required for loadData */
data_line([Direction, Units], Line) :- split_string(Line, " ", "", [Direction, UnitsStr]), number_string(Units, UnitsStr).
