firstCol([], [], []).
firstCol([[H|T]|Rows], [H|Hs], [T|Ts]) :- firstCol(Rows, Hs, Ts).

hasWon(F, DRAWN) :- hasWonRow(F, DRAWN), !.
hasWon(F, DRAWN) :- hasWonCol(F, DRAWN), !.
hasWonRow([H|_], DRAWN) :- subset(H, DRAWN), !.
hasWonRow([_|T], DRAWN) :- hasWonRow(T, DRAWN).
hasWonCol(F, DRAWN) :- firstCol(F, C1, _), subset(C1, DRAWN), !.
hasWonCol(F, DRAWN) :- firstCol(F, _, CR), hasWonCol(CR, DRAWN).

allBoardsWon([], _).
allBoardsWon([FIRST_BOARD|OTHER_BOARDS], DRAWN) :- hasWon(FIRST_BOARD, DRAWN), allBoardsWon(OTHER_BOARDS, DRAWN).

member([H|T], H, T).
member([H|T], M, [H|MT]) :- member(T, M, MT).

loosingBoard(BOARDS, _, DRAWN, LOOSING_BOARD) :-
  member(BOARDS, LOOSING_BOARD, WINNING_BOARDS),
  not(hasWon(LOOSING_BOARD, DRAWN)),
  allBoardsWon(WINNING_BOARDS, DRAWN).
loosingBoard(BOARDS, [NEXT_DRAW|OTHER_DRAWS], DRAWN, LOOSING_BOARD) :- loosingBoard(BOARDS, OTHER_DRAWS, [NEXT_DRAW|DRAWN], LOOSING_BOARD).

winningBoard([H|_], DRAWN, H) :- hasWon(H, DRAWN), !.
winningBoard([_|T], DRAWN, W) :- winningBoard(T, DRAWN, W).

firstWinningBoard(BOARDS, _, DRAWN, WINNING_SCORE) :- winningBoard(BOARDS, DRAWN, WINNING_BOARD), board_score(WINNING_BOARD, DRAWN, WINNING_SCORE).
firstWinningBoard(BOARDS, [H|T], DRAWN, WINNING_SCORE) :- firstWinningBoard(BOARDS, T, [H|DRAWN], WINNING_SCORE).

board_score(BOARD, _, DRAWN, SCORE) :- hasWon(BOARD, DRAWN), board_score(BOARD, DRAWN, SCORE).
board_score(BOARD, [FIRST_DRAW|OTHER_DRAWS], DRAWN, SCORE) :- board_score(BOARD, OTHER_DRAWS, [FIRST_DRAW|DRAWN], SCORE).
board_score(BOARD, [H|T], SCORE) :- flatten(BOARD, FLAT_BOARD), board_unmarked(FLAT_BOARD, [H|T], UNMARKED), SCORE is H * UNMARKED.
board_unmarked(FLAT_BOARD, DRAWN, UNMARKED) :- subtract(FLAT_BOARD, DRAWN, UNMARKED_LIST), sum_list(UNMARKED_LIST, UNMARKED).

result([DRAWS|BOARDS], SCORE) :- loosingBoard(BOARDS, DRAWS, [], LOOSING_BOARD), board_score(LOOSING_BOARD, DRAWS, [], SCORE).

day(4). testResult(1924). groupData. solve :- ['lib/solve.prolog'], printResult.

/* required for loadData */
data_header(DATA, HEADER) :- 
  split_string(HEADER, ",", " ", NUMBER_STRS), numbers_strings(DATA, NUMBER_STRS).
data_line(DATA, LINE) :-
  split_string(LINE, " ", " ", NUMBER_STRS), numbers_strings(DATA, NUMBER_STRS).

numbers_strings([], []).
numbers_strings([NH|NT], [SH|ST]) :- number_string(NH, SH), numbers_strings(NT, ST).
