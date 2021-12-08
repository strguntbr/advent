horizontal(line{start: pos{x: X, y: _}, end: pos{x: X, y: _}}).
vertical(line{start: pos{x: _, y: Y}, end: pos{x: _, y: Y}}).

assertDangerAt(X, Y) :- dangerAt(X, Y), !. assertDangerAt(X, Y) :- assert(dangerAt(X, Y)).
mark(X, Y) :- ventAt(X, Y), !, assertDangerAt(X, Y).
mark(X, Y) :- assert(ventAt(X, Y)).

markHorizontal(X, END_Y, END_Y) :- !, mark(X, END_Y).
markHorizontal(X, Y, END_Y) :- mark(X, Y), Yn is Y+1, markHorizontal(X, Yn, END_Y).

markVertical(Y, END_X, END_X) :- !, mark(END_X, Y).
markVertical(Y, X, END_X) :- mark(X, Y), Xn is X+1, markVertical(Y, Xn, END_X).

processVent(L) :- horizontal(L), !, START_Y is min(L.start.y, L.end.y), END_Y is max(L.start.y, L.end.y), markHorizontal(L.start.x, START_Y, END_Y).
processVent(L) :- vertical(L), !, START_X is min(L.start.x, L.end.x), END_X is max(L.start.x, L.end.x), markVertical(L.start.y, START_X, END_X).
processVent(_).

processVents([]).
processVents([H|T]) :- processVent(H), processVents(T).

result(VENTS, SCORE) :- retractall(ventAt(_, _)), retractall(dangerAt(_, _)), processVents(VENTS),  aggregate_all(count, dangerAt(_, _), SCORE).

day(5). testResult(5). solve :- ['lib/solve.prolog'], printResult.

/* required for loadData */
data_line(line{start: START_COORDS, end: END_COORDS}, LINE) :-
  split_string(LINE, ">", "- ", [START, END]),
  string_coords(START, START_COORDS),
  string_coords(END, END_COORDS).

string_coords(STRING, pos{x: X, y: Y}) :- split_string(STRING, ",", "", [X_STR,Y_STR]), number_string(X, X_STR), number_string(Y, Y_STR).
