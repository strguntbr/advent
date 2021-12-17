:- include('17.common.prolog'). testResult(112).

result([TargetArea], Possibilities) :-
  setof(InitialVector, initialVector(TargetArea, InitialVector), AllInitialVectors),
  length(AllInitialVectors, Possibilities).

initialVector(TargetArea, [X, Y]) :-
  initialY(TargetArea, Y), initialX(TargetArea, X),
  ySteps(TargetArea.minY, TargetArea.maxY, Y, YSteps), same_length(YSteps, XSteps), xSteps(TargetArea.minX, TargetArea.maxX, X, XSteps).

initialY(TargetArea, InitialY) :- Min is TargetArea.minY, Max is -TargetArea.minY - 1, between(Min, Max, InitialY).
initialX(TargetArea, InitialX) :- Min is ceil(-1/2 + sqrt(1/4 + 2 * TargetArea.minX)), Max is TargetArea.maxX, between(Min, Max, InitialX).

xSteps(MinX, MaxX, _, []) :- MinX =< 0, MaxX >= 0.
xSteps(MinX, MaxX, InitialVector, [InitialVector|NextSteps]) :- MaxX > 0,
  (InitialVector > 0 -> NextVector is InitialVector - 1 ; NextVector = 0),
  xSteps(MinX - InitialVector, MaxX - InitialVector, NextVector, NextSteps).

ySteps(MinY, MaxY, _, []) :- MinY =< 0, MaxY >= 0.
ySteps(MinY, MaxY, InitialVector, [InitialVector|NextSteps]) :- MinY < 0,
  NextVector is InitialVector - 1,
  ySteps(MinY - InitialVector, MaxY - InitialVector, NextVector, NextSteps).

/* 
 * Unforunately the solution below does not work, because when just combining the results of the individual X and Y calculations you end up counting
 * some initial vectors twice (because the probe might be in the target area for 2 or more consecutive times for on initial vector)   
 */
/*
result([TargetArea], Possibilities) :- 
  MaxStepCount is (-TargetArea.minY) * 2,
  findall(S, between(1, MaxStepCount, S), Steps),
  maplist(
    [S,P] >> (
      xCount(S, [TargetArea.minX, TargetArea.maxX], X),
      yCount(S, [TargetArea.minY, TargetArea.maxY], Y),
      P is X * Y,
      ( P > 0 -> format('~w: ~w * ~w = ~w~n', [S, X, Y, P]) ; true)
    ),
    Steps, Products
  ),
  sum_list(Products, Possibilities).

xCount(S, [Min, Max], C) :- 
  T is ceil(1/2 + sqrt(1/4 + 2 * Min)),
  (
      S > T -> xCount(T, [Min, Max], C)
      ; C is floor(Max / S - (S-1) / 2) - ceiling(Min / S - (S-1) / 2) + 1
  ).

yCount(S, [Min, Max], C) :- C is floor(Max / S - (S-1) / 2) - ceiling(Min / S - (S-1) / 2) + 1.
*/
