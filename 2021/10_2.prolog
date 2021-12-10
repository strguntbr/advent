matches('(', ')'). matches('[', ']'). matches('{', '}'). matches('<', '>').
score(')', 1). score(']', 2). score('}', 3). score('>', 4).

completionScore([], 0).
completionScore([H|T], SCORE) :- completionScore(T, SCOREt), score(H, SCOREh), SCORE is SCOREt * 5 + SCOREh.

autocompleteScore([], MISSING_CLOSES, SCORE) :- !, reverse(MISSING_CLOSES, REVERSE), completionScore(REVERSE, SCORE). /* incomplete line */
autocompleteScore([H|T], C, ERROR) :- matches(H, Hc), !, autocompleteScore(T, [Hc|C], ERROR). /* opening */
autocompleteScore([H|T], [H|Tc], ERROR) :- !, autocompleteScore(T, Tc, ERROR). /* closing */
autocompleteScore([_|_], _, _) :- fail. /* syntax error, ignore it */
autocompleteScore(NAV_INSTRUCTIONS, ERROR) :- autocompleteScore(NAV_INSTRUCTIONS, [], ERROR), !.

median(LIST, MEDIAN) :- sort(LIST, SORTED), length(LIST, LENGTH), N is (LENGTH - 1) / 2, nth0(N, SORTED, MEDIAN).

result(NAVIGATION_DATA, MEDIAN_SCORE) :-
  convlist(autocompleteScore, NAVIGATION_DATA, SCORES),
  median(SCORES, MEDIAN_SCORE).

day(10). testResult(288957). solve :- ['lib/solve.prolog'], printResult.

/* required for loadData */
data_line(NAV_INSTRUCTION, LINE) :- string_chars(LINE, NAV_INSTRUCTION).
