:- include('4.common.prolog'). testResult(4512).

result([AllDraws|Boards], Score) :- 
  aggregate_all(
    min(C, [Board, Draws]),
    (member(Board, Boards), drawsToWin(AllDraws, Board, Draws), length(Draws, C)),
    min(_, [FirstWinningBoard, DrawsToWin])
  ),
  board_score(FirstWinningBoard, DrawsToWin, Score).
