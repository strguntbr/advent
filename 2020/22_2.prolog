day(22).

getSubDeck(_, 0, []).
getSubDeck([H|T], Length, [H|SubT]) :- SubLength is Length-1, getSubDeck(T, SubLength, SubT).

updateDecks(P1Deck, P2Deck, P1Card, P2Card, 1, P1UpdatedDeck, P2Deck) :- append(P1Deck, [P1Card, P2Card], P1UpdatedDeck).
updateDecks(P1Deck, P2Deck, P1Card, P2Card, 2, P1Deck, P2UpdatedDeck) :- append(P2Deck, [P2Card, P1Card], P2UpdatedDeck).

playRound([P1h|P1t], [P2h|P2t], Winner) :-
  getSubDeck(P1t, P1h, P1SubDeck), getSubDeck(P2t, P2h, P2SubDeck), !,
  playGame(P1SubDeck, P2SubDeck, Winner, _).
playRound([P1h|_], [P2h|_], 1) :- P1h > P2h.
playRound([P1h|_], [P2h|_], 2) :- P1h < P2h.

play([P1h|_], [P2h|_], _, _, _, _) :- P1h = P2h, !, fail.
play(Player1, [], _, Player1, [], 1) :- !.
play([], Player2, _, [], Player2, 2) :- !.
play(Player1, Player2, PlayStates, Player1, Player2, 1) :- member([Player1,Player2], PlayStates), !.
play([P1h|P1t], [P2h|P2t], PlayStates, Player1Result, Player2Result, Winner) :-
  playRound([P1h|P1t], [P2h|P2t], SubWinner),
  updateDecks(P1t, P2t, P1h, P2h, SubWinner, P1n, P2n),
  play(P1n, P2n, [[[P1h|P1t],[P2h|P2t]]|PlayStates], Player1Result, Player2Result, Winner).

playGame(Player1, Player2, Winner, WinningDeck) :-
  play(Player1, Player2, [], Player1Result, Player2Result, Winner),
  winner(Player1Result, Player2Result, Winner, WinningDeck).

winner(Player1, _, 1, Player1). winner(_, Player2, 2, Player2).

score([], _, 0).
score(ReverseDeck, Multiplier, Score) :- 
  ReverseDeck = [BottomCard|RestOfDeck],
  NextMultiplier is Multiplier+1,
  score(RestOfDeck, NextMultiplier, NextScore),
  Score is NextScore+Multiplier*BottomCard.
score(Player, Score) :- reverse(Player, ReverseDeck), score(ReverseDeck, 1, Score).

solve(File) :-
  set_prolog_flag(stack_limit, 2_147_483_648),
  loadData(File, Player1, Player2),
  playGame(Player1, Player2, _, WinningDeck),
  score(WinningDeck, WinningScore),
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