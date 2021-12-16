:- include('4.common.prolog'). testResult(1924).

result([AllDraws|Boards], Score) :- 
  aggregate_all(
    max(C, [Board, Draws]),
    (member(Board, Boards), drawsToWin(AllDraws, Board, Draws), length(Draws, C)),
    max(_, [LastWinningBoard, DrawsToWin])
  ),
  board_score(LastWinningBoard, DrawsToWin, Score).
