:- include('17.common.prolog'). testResult(112).

result([TargetArea], Possibilities) :-
  findall(InitialVector, initialVector(TargetArea, InitialVector), AllInitialVectors),
  length(AllInitialVectors, Possibilities).

initialVector(TargetArea, [X, Y]) :-
  initialY(TargetArea, Y), initialX(TargetArea, X),
  hitsTarget([TargetArea.minX, TargetArea.maxX], [TargetArea.minY, TargetArea.maxY], [X, Y]).

initialY(TargetArea, InitialY) :- Min is TargetArea.minY, Max is -TargetArea.minY - 1, between(Min, Max, InitialY).
initialX(TargetArea, InitialX) :- Min is ceil(-1/2 + sqrt(1/4 + 2 * TargetArea.minX)), Max is TargetArea.maxX, between(Min, Max, InitialX).

hitsTarget([MinX, MaxX], [MinY, MaxY], _) :- MinX =< 0, MaxX >= 0, MinY =< 0, MaxY >= 0, !.
hitsTarget([MinX, MaxX], [MinY, MaxY], [VectorX, VectorY]) :- MinY =< 0, MaxX >= 0,
  incrementXVector(VectorX, NextVectorX), incrementYVector(VectorY, NextVectorY),
  hitsTarget([MinX-VectorX, MaxX-VectorX], [MinY-VectorY, MaxY-VectorY], [NextVectorX, NextVectorY]).

incrementXVector(Cur, Next) :- (Cur = 0 -> Next = 0 ; Next is Cur -1).
incrementYVector(Cur, Next) :- Next is Cur - 1.
