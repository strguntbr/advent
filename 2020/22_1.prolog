day(22).

play([P1h|_], [P2h|_], _, _) :- P1h = P2h, !, fail.
play(Player1, [], Player1, []) :- !.
play([P1h|P1t], [P2h|P2t], P1Result, P2Result) :- P1h > P2h, !, append(P1t, [P1h,P2h], P1Next), play(P1Next, P2t, P1Result, P2Result).
play(Player1, Player2, Player1Result, Player2Result) :- play(Player2, Player1, Player2Result, Player1Result).  

winner(Player1, [], Player1). winner([], Player2, Player2).
score([], _, 0).
score(ReverseDeck, Multiplier, Score) :- 
  ReverseDeck = [BottomCard|RestOfDeck],
  NextMultiplier is Multiplier+1,
  score(RestOfDeck, NextMultiplier, NextScore),
  Score is NextScore+Multiplier*BottomCard.
score(Player, Score) :- reverse(Player, ReverseDeck), score(ReverseDeck, 1, Score).

solve(File) :-
  loadData(File, Player1, Player2),
  play(Player1, Player2, Player1Result, Player2Result),
  winner(Player1Result, Player2Result, Winner),
  score(Winner, WinningScore),
  !, write(WinningScore).
solveTest :- ['lib/loadData.prolog'], day(DAY), solveTestDay(DAY).
solveTest(N) :- ['lib/loadData.prolog'], day(DAY), solveTestDay(DAY, N).
solve :- ['lib/loadData.prolog'], day(DAY), solveDay(DAY).

loadData(File, Player1, Player2) :- reset, loadGroupedData([[_|Player1],[_|Player2]], File).
reset.

/* required for loadData */
data_line([], PlayerHeader) :- sub_string(PlayerHeader, 0, _, _, "Player "), !.
data_line(Card, Line) :- number_string(Card, Line).

tail([_|T], T).