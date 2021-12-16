day(4). groupData. solve :- ['lib/solve.prolog'], printResult.

:- include('lib/matrix.prolog').

drawsToWin(Draws, Board, RequiredDraws) :-
  aggregate_all(min(L, D), (append(D, _, Draws), length(D, L), hasWon(Board, D)), min(_, RequiredDraws)).

hasWon(Board, Draws) :-
  (col(Line, Board) ; row(Line, Board)),
  forall(member(Number, Line), member(Number, Draws)).

board_score(Board, Draws, Score) :- 
  append(Board, Numbers),
  aggregate_all(sum(Number), (member(Number, Numbers), not(member(Number, Draws))), Sum),
  last(Draws, Last), Score is Sum * Last.

/* required for loadData */
data_header(Draws, Header) :- split_string(Header, ",", " ", NumberStr), maplist(number_string, Draws, NumberStr).
data_line(BoardLine, Line) :- split_string(Line, " ", " ", NumberStr), maplist(number_string, BoardLine, NumberStr).
