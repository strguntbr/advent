:- include('17.common.prolog'). testResult(112).

result([TargetArea], Possibilities) :- 
  MaxStepCount is (-TargetArea.minY) * 2,
  findall(S, between(1, MaxStepCount, S), Steps),
  maplist(
    [S,P] >> (
      xCount(S, [TargetArea.minX, TargetArea.maxX], X),
      yCount(S, [TargetArea.minY, TargetArea.maxY], Y),
      xDuplicates(S, [TargetArea.minX, TargetArea.maxX], XD, _, _),
      yDuplicates(S, [TargetArea.minY, TargetArea.maxY], YD, _, _),
      P is X * Y - XD * YD
    ),
    Steps, Products
  ),
  sum_list(Products, Possibilities).

xCount(S, [Min, Max], C) :- T is min(S, ceiling(1/2 + sqrt(1/4 + 2 * Min))), C is floor(Max / T - (T-1) / 2) - ceiling(Min / T - (T-1) / 2) + 1.

yCount(S, [Min, Max], C) :- C is floor(Max / S - (S-1) / 2) - ceiling(Min / S - (S-1) / 2) + 1.

yDuplicates(S, [Min, Max], C, SmallestFinalVector, Sum) :- 
  SmallestFinalVector is ceil(Min/S - S/2 + 1/2),
  Sum is (2*SmallestFinalVector + S - 1)*S/2,
  (
    Sum - SmallestFinalVector =< Max -> C is floor((Max - (Sum - SmallestFinalVector)) / (S-1)) + 1
    ; C = 0
  ).

xDuplicates(S, [Min, Max], C, SmallestFinalVector, Sum) :- 
  SmallestFinalVector is floor(Max/S - S/2 + 1/2),
  Sum is (2*SmallestFinalVector + S - 1)*S/2,
  (
    SmallestFinalVector =< 0 -> SN is S - 1, xDuplicates(SN, [Min, Max], C, _, _)
    ; Sum - SmallestFinalVector >= Min -> C is floor(((Sum - SmallestFinalVector) - Min) / (S-1)) + 1
    ; C = 0
  ).
