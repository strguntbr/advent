countTree([['#'|_]|_], OLD_COUNT, NEW_COUNT) :- NEW_COUNT is OLD_COUNT+1, !.
countTree(_, COUNT, COUNT).

trees(_, _, _, _, 0, []) :- !.
trees(Vxi, 0, Vyi, 0, COUNT, LINES) :- !, trees(Vxi, Vxi, Vyi, Vyi, NEW_COUNT, LINES), countTree(LINES, NEW_COUNT, COUNT).
trees(Vxi, 0, Vyi, Vy, COUNT, [_|OTHER_LINES]) :- !, Vyn is Vy-1, trees(Vxi, 0, Vyi, Vyn, COUNT, OTHER_LINES).
trees(Vxi, Vx, Vyi, Vy, COUNT, LINES) :- Vxn is Vx-1, rotate_lists(LINES, ROTATED_LINES), trees(Vxi, Vxn, Vyi, Vy, COUNT, ROTATED_LINES).
trees(Vxi, Vyi, COUNT, LINES) :- trees(Vxi, 0, Vyi, 0, COUNT, LINES).

rotate_list([], []).
rotate_list([H|T], L) :- append(T, [H], L).
rotate_lists([], []).
rotate_lists([H1|T1], [H2|T2]) :- rotate_list(H1, H2), rotate_lists(T1, T2).

solve(FILE) :- ['lib/loadData.prolog'], loadData(DATA, FILE), trees(3, 1, COUNT, DATA), write(COUNT).
solve :- solve('input/3.data').

/* required for loadData */
data_line(DATA, LINE) :- string_chars(LINE, DATA).