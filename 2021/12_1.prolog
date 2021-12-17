:- include('lib/solve.prolog'). day(12). testResult('test1', 10). testResult('test2', 19). testResult('test3', 226).

member([H|T], H, T).
member([H|T], M, [H|MT]) :- member(T, M, MT).

pickCave(CAVES, CAVE, REMAINING_CAVES) :-
  member(CAVES, CAVE, OTHER_CAVES),
  (
    bigCave(CAVE) -> REMAINING_CAVES = CAVES
    ; REMAINING_CAVES = OTHER_CAVES
  ).
areConnected(CAVE1, CAVE2) :- connection(CAVE1, CAVE2) ; connection(CAVE2, CAVE1).
bigCave(CAVE) :- string_code(1, CAVE, LETTER), LETTER >= 65, LETTER =< 90.

path(START, START, _, []).
path(START, END, CAVES, [NEXT|PATH]) :- pickCave(CAVES, NEXT, REMAINING_CAVES), areConnected(START, NEXT), path(NEXT, END, REMAINING_CAVES, PATH).

findPath(CAVES, PATH) :- path("start", "end", CAVES, PATH).

result(_, PATH_COUNT) :- 
  findall(CAVE, cave(CAVE), ALL_CAVES),
  pickCave(ALL_CAVES, "start", CAVES),
  aggregate_all(count, findPath(CAVES, _), PATH_COUNT).

/* required for loadData */
data_line([START, END], LINE) :-
  split_string(LINE, '-', '', [START, END]), assert(connection(START, END)),
  retractall(cave(START)), retractall(cave(END)), assert(cave(START)), assert(cave(END)).

resetData :- retractall(connection(_, _)).