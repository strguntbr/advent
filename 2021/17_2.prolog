:- include('17.common.prolog'). testResult(112).

result([TargetArea], Possibilities) :- 
  MaxStepCount is (-TargetArea.minY) * 2,
  aggregate_all(sum(P), (
    between(1, MaxStepCount, S),
    xCount(S, [TargetArea.minX, TargetArea.maxX], X),
    yCount(S, [TargetArea.minY, TargetArea.maxY], Y),
    xDuplicates(S, [TargetArea.minX, TargetArea.maxX], XD),
    yDuplicates(S, [TargetArea.minY, TargetArea.maxY], YD),
    P is X * Y - XD * YD
  ), Possibilities).

yCount(N, [Min, Max], C) :-
  /*
   * Just calculate the smallest [ ceiling(Min/N - (N-1)/2) ] and largest [ floor(Max / N - (N-1) / 2) ] final vector and check the distance between those two (1 is added because both _smallest_ and _largest_ are a possibility)
   */
  C is floor(Max/N - (N-1)/2) - ceiling(Min/N - (N-1)/2) + 1.

  /*
   * The idea is to first find the maximum number of steps that not only return possibilites padded by zeros at the end [ ceil(1/2 + sqrt(1/4 + 2 * Min)) ].
   * We limit N to this value, as every N greater than that will return the same number of possibilites (exactly the same possibilties padded with zeros at the end)
   * Then we do the same calculation as for the yCount (but use the limited value instead of N).
   */
xCount(N, [Min, Max], C) :- T is min(N, ceiling(1/2 + sqrt(1/4 + 2 * Min))), C is floor(Max/T - (T-1)/2) - ceiling(Min / T - (T-1)/2) + 1.

yDuplicates(N, [Min, Max], C) :-
  /*
   * The idea is to find the smallest (as the final vector is negative this means it will have the largest absolute value) final vector [ ceil(Min/N - N/2 + 1/2) ].
   * Next we calculate the sum [ (2*SmallestFinalVector + N - 1)*N/2 ] of the possibility with the smallest final vector (this will also be the smallest (again, as the sums are negative it means it has the largest absolute value) sum for N).
   * Then we calculate on how many possibilities we can remove the final vector [ floor((Max - (SmallestSum - SmallestFinalVector)) / (N-1)) + 1 ] to still stay in the target area (keep the result =< Max) (=> Those are duplicates).
   * All those steps have been summed up in one formula that was then simplified.
   */
 C is max(0, floor((Max - ((N-1)*ceiling(Min/N - N/2 + 1/2) + N*N/2 - N/2)) / max(1, N-1)) + 1). /* max(1, N-1) is a workaround to handle the case of N=1 that would result in a division by zero. If n=1 the numerator will be -Min and thus the whole division will be negative and set to 0 anyway by the outer max operation, so we can just replace 0 with 1 for the division */

xDuplicates(N, [Min, Max], C) :- 
  /*
   * The idea is to find the largest final vector [ floor(Max/N - N/2 + 1/2)) ].
   * Next we calculate the sum [ (2*LargestFinalVector + N - 1)*N/2 ] of the possibility with the largest final vector (this will also be the largest sum for N).
   * Then we calculate on how many possibilities we can remove the final vector [ floor(((LargestSum - LargestFinalVector) - Min) / (N-1)) + 1 ] to still stay in the target area (keep the result >= Min) (=> Those are duplicates).
   * The last 2 steps have been summed up in one formula that was then simplified.
   */
  V is floor(Max/N - N/2 + 1/2),
  (
    V =< 0 -> xCount(N, [Min, Max], C) /* The final vector of all possibilities is 0. Thus the final vector can be removed from all possibilities => everything is a duplicate */
    ; C is max(0, floor((((N-1)*V + N*N/2 - N/2) - Min) / max(1, N-1)) + 1) /* max(1, N-1) is a workaround to handle the case of N=1 that would result in a division by zero. If n=1 the numerator will be -Min and thus the whole division will be negative and set to 0 anyway by the outer max operation, so we can just replace 0 with 1 for the division */
  ).
