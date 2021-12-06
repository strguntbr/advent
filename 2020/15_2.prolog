inc(I, In) :- plus(I, 1, In).

lastOccurrence(MEMORY, NUMBER, PREVROUND, AGE) :-
  ( trie_lookup(MEMORY, NUMBER, LAST) ->
    AGE is PREVROUND - LAST;
    AGE is 0
  ),
  trie_update(MEMORY, NUMBER, PREVROUND).

init([H|[]], _, _, H) :- !.
init([H|T], C, MEMORY, NUMBER) :- inc(C, Ct), trie_insert(MEMORY, H, C), init(T, Ct, MEMORY, NUMBER).
init(INPUT_LIST, MEMORY, STARTING_NUMBER) :- trie_new(MEMORY), init(INPUT_LIST, 0, MEMORY, STARTING_NUMBER).

nthNumber(0, MEMORY, PREV_NUMBER, ROUND, NUMBER) :- !, lastOccurrence(MEMORY, PREV_NUMBER, ROUND, NUMBER).
nthNumber(C, MEMORY, PREV_NUMBER, ROUND, NUMBER) :-
  lastOccurrence(MEMORY, PREV_NUMBER, ROUND, NEXT_NUMBER),
  NEXT_ROUND is ROUND+1, NEXT_C is C-1,
  nthNumber(NEXT_C, MEMORY, NEXT_NUMBER, NEXT_ROUND, NUMBER).

solve(NUMBERS, N, RESULT) :-
  init(NUMBERS, MEMORY, STARTING_NUMBER),
  length(NUMBERS, L_SO_FAR),
  plus(L_SO_FAR, T, N), inc(COUNT, T), inc(ROUND, L_SO_FAR),
  nthNumber(COUNT, MEMORY, STARTING_NUMBER, ROUND, RESULT).

solve(FILE) :-
  loadData([NUMBERS], FILE),
  solve(NUMBERS, 30_000_000, RESULT),
  write(RESULT).
solveTest :- ['lib/loadData.prolog'], solveTestDay(15).
solveTest(N) :- ['lib/loadData.prolog'], solveTestDay(15, N).
solve :- ['lib/loadData.prolog'], solveDay(15).

/* required for loadData */
data_line(NUMBERS, LINE) :- split_string(LINE, ",", "", STRINGS), numbers_strings(NUMBERS, STRINGS).
numbers_strings([], []).
numbers_strings([Hn|Tn], [Hs|Ts]) :- number_string(Hn, Hs), numbers_strings(Tn, Ts).