horizontal(line{start: pos{x: X, y: _}, end: pos{x: X, y: _}}).
vertical(line{start: pos{x: _, y: Y}, end: pos{x: _, y: Y}}).
diagonal_forward(line{start: pos{x: X1, y: Y1}, end: pos{x: X2, y: Y2}}) :- Xd is X2-X1, Yd is Y2-Y1, Xd == Yd.
diagonal_backward(line{start: pos{x: X1, y: Y1}, end: pos{x: X2, y: Y2}}) :- Xd is X2-X1, Yd is Y1-Y2, Xd == Yd.

maxX([], 0).
maxX([H|T], X) :- maxX(T, Tx), maxX_(H, Hx), max(Hx, Tx, X).
maxX_(LINE, X) :- max(LINE.start.x, LINE.end.x, X).

maxY([], 0).
maxY([H|T], Y) :- maxY(T, Ty), maxY_(H, Hy), max(Hy, Ty, Y).
maxY_(LINE, Y) :- max(LINE.start.y, LINE.end.y, Y).

max(A, B, A) :- A > B, !. max(_, B, B).

on_n_lines(_, 0, _, _) :- !.
on_n_lines([FIRST_LINE|OTHER_LINES], N, X, Y) :- on_line(FIRST_LINE, X, Y), !, Nn is N - 1, on_n_lines(OTHER_LINES, Nn, X, Y).
on_n_lines([_|OTHER_LINES], N, X, Y) :- on_n_lines(OTHER_LINES, N, X, Y).
on_line(LINE, X, Y) :- horizontal(LINE), LINE.start.x == X, isBetween(LINE.start.y, LINE.end.y, Y).
on_line(LINE, X, Y) :- vertical(LINE), LINE.start.y == Y, isBetween(LINE.start.x, LINE.end.x, X).
on_line(LINE, X, Y) :- diagonal_forward(LINE), isBetween(LINE.start.x, LINE.end.x, X), Yd is LINE.start.y - Y, Xd is LINE.start.x - X, Yd == Xd.
on_line(LINE, X, Y) :- diagonal_backward(LINE), isBetween(LINE.start.x, LINE.end.x, X), Yd is LINE.start.y - Y, Xd is X - LINE.start.x, Yd == Xd.

isBetween(MIN, MAX, X) :- MIN >= X, X >= MAX.
isBetween(MAX, MIN, X) :- MIN >= X, X >= MAX.

on_2_lines(LINES, MAX_X, MAX_Y, X, Y) :-
  between(0, MAX_X, X), between(0, MAX_Y, Y),
  on_n_lines(LINES, 2, X, Y).

result(LINES, SCORE) :-
  maxX(LINES, MAX_X), maxY(LINES, MAX_Y),
  aggregate_all(count, on_2_lines(LINES, MAX_X, MAX_Y, _, _), SCORE).

day(5). testResult(12). solve :- ['lib/solve.prolog'], printResult.

/* required for loadData */
data_line(line{start: START_COORDS, end: END_COORDS}, LINE) :-
  split_string(LINE, ">", "- ", [START, END]),
  string_coords(START, START_COORDS),
  string_coords(END, END_COORDS).

string_coords(STRING, pos{x: X, y: Y}) :- split_string(STRING, ",", "", [X_STR,Y_STR]), number_string(X, X_STR), number_string(Y, Y_STR).
