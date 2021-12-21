:- include('lib/solve.prolog'). day(21). testResult(739785).

result([StartA,StartB], Result) :-
  play(StartA, StartB, 1, 0, 0, _, LoosingScore, Rolls),
  Result is LoosingScore * Rolls.

play(_, _, _, ScoreA, ScoreB, ScoreB, ScoreA, 6) :- ScoreB >= 1000, !.
play(PosA, PosB, Dice, ScoreA, ScoreB, WinningScore, LoosingScore, Rolls) :-
  roll(Dice, ValueA, DiceAfterA), move(PosA, ValueA, NextPosA), NextScoreA is ScoreA + NextPosA,
  (
    NextScoreA >= 1000 -> WinningScore=NextScoreA, LoosingScore=ScoreB, Rolls = 3
    ;
    roll(DiceAfterA, ValueB, NextDice), move(PosB, ValueB, NextPosB), NextScoreB is ScoreB + NextPosB,
    play(NextPosA, NextPosB, NextDice, NextScoreA, NextScoreB, WinningScore, LoosingScore, NextRolls),
    Rolls is NextRolls + 6
  ).

move(Pos, Value, NewPos) :- NewPos is mod(Pos + Value - 1, 10) + 1.

roll(Dice, Value, NextDice) :- Value is Dice + mod(Dice, 100) + mod(Dice+1, 100) + 2 , NextDice is mod(Dice+2, 100) + 1.

/* required for loadData */
data_line(StartingPosition, Line) :- split_string(Line, ':', ' ', [_, StartStr]), number_string(StartingPosition, StartStr).
