:- include('lib/solve.prolog'). day(13). testResult(17). groupData.

result([Dots, [Instruction1|_]], DotCount) :- fold(Dots, [Instruction1], FoldedDots), length(FoldedDots, DotCount).

fold(Dots, [], Dots).
fold(Dots, [Instruction1|OtherInstructions], FoldedDots) :- singleFold(Dots, Instruction1, NextDots), fold(NextDots, OtherInstructions, FoldedDots).

singleFold(Dots, Instruction, UniqueFoldedDots) :- maplist([X,Y]>>foldDot(X, Instruction, Y), Dots, FoldedDots), unique(FoldedDots, UniqueFoldedDots).

unique([], []). unique([H|T], Unique) :- unique(T, TUnique), (member(H, TUnique) -> Unique = TUnique ; Unique = [H|TUnique]).

foldDot(dot{x: XIn, y: YIn}, fold{axis: 'x', at: Line}, dot{x: XFold, y: YIn}) :- mirror(XIn, Line, XFold).
foldDot(dot{x: XIn, y: YIn}, fold{axis: 'y', at: Line}, dot{x: XIn, y: YFold}) :- mirror(YIn, Line, YFold).
mirror(Value, At, MirroredValue) :- (Value < At -> MirroredValue = Value ; MirroredValue is (2 * At - Value)).

/* required for loadData */
data_line(Dot, Line) :- dot_line(Dot, Line).
data_line(Instruction, Line) :- instruction_line(Instruction, Line).

dot_line(dot{x: X, y: Y}, Line) :- split_string(Line, ',', '', [XStr, YStr]), number_string(X, XStr), number_string(Y, YStr).
instruction_line(Instruction, Line) :- split_string(Line, '=', '', [Axis, FoldLineStr]), number_string(FoldLine, FoldLineStr), instruction(Axis, FoldLine, Instruction).
instruction("fold along x", FoldLine, fold{axis: 'x', at: FoldLine}).
instruction("fold along y", FoldLine, fold{axis: 'y', at: FoldLine}).
