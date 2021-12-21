:- include('lib/solve.prolog'). day(21). testResult(444356092776315).

result([StartA,StartB], Result) :-
  aggregate_all(
    sum(AWins),
    (
       /*
        * The safe choice of range for S for an arbitrary number of games N would be to just pick
        * 1..N. But we have a little bit of knowledge of the game we can reduce it for our case:
        *
        * As 3 dice rolls always end in a sum between 3 an 9
        * - at least 3 steps are required to end a game
        *     (e.g. when starting at 4 and rolling 5,9,9 wich makes you end up on fields 9,8,7
        *     that sum up to 24)
        * - at most 10 steps are required to end a game
        *     (e.g. when starting at 4 and rolling 9,3,8,9,3,8,9,3,9 which makes you end up on
        *     the fields 1,4,2,1,4,2,1,4 that sum up to 20, so on the next (the 10th step the
        *     game will be over))
        */
      between(3, 10, S),
      winsWith(S, StartA, 0, 21, WA),
      loosesWith(S - 1, StartB, 0, 21, LB),
      AWins is WA*(LB)
    ),
    TotalWinsA  
  ),
  aggregate_all(
    sum(BWins),
    (
      between(3, 10, S),
      winsWith(S, StartB, 0, 21, WB),
      loosesWith(S, StartA, 0, 21, LA),
      BWins is WB*LA
    ),
    TotalWinsB
  ),
  Result is max(TotalWinsA, TotalWinsB).

winsWith(Steps, Pos, Score, TargetScore, Combinations) :-
  Steps < 0 -> fail ;
  Score >= TargetScore -> (Steps = 0 -> Combinations = 1 ; fail) ;
  aggregate_all(
    sum(C),
    (
      move(Pos, NextPos, C1), NextScore is Score + NextPos, NextSteps is Steps - 1,
      winsWith(NextSteps, NextPos, NextScore, TargetScore, C2),
      C is C1*C2
    ),
    Combinations
  ).

loosesWith(Steps, Pos, Score, TargetScore, Combinations) :-
  Score >= TargetScore -> fail ;
  Steps = 0 -> (Score < TargetScore -> Combinations = 1 ; fail) ;
  aggregate_all(
    sum(C),
    (
      move(Pos, NextPos, C1), NextScore is Score + NextPos, NextSteps is Steps - 1,
      loosesWith(NextSteps, NextPos, NextScore, TargetScore, C2),
      C is C1*C2
    ),
    Combinations
  ).
  
move(Start, End, Combinations) :- roll(X, Combinations), End is mod(Start+X-1, 10)+1.

roll(3, 1).
roll(9, 1).
roll(4, 3).
roll(8, 3).
roll(5, 6).
roll(7, 6).
roll(6, 7).

/* required for loadData */
data_line(StartingPosition, Line) :- split_string(Line, ':', ' ', [_, StartStr]), number_string(StartingPosition, StartStr).
