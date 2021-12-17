:- include('lib/solve.prolog'). day(10). testResult(26397).

matches('(', ')'). matches('[', ']'). matches('{', '}'). matches('<', '>').
score(')', 3). score(']', 57). score('}', 1197). score('>', 25137).

syntaxError([], _, _) :- fail. /* incomplete line, ignore it */
syntaxError([H|T], C, ERROR) :- matches(H, Hc), !, syntaxError(T, [Hc|C], ERROR). /* opening */
syntaxError([H|T], [H|Tc], ERROR) :- !, syntaxError(T, Tc, ERROR). /* closing */
syntaxError([H|_], _, ERROR) :- score(H, ERROR). /* syntax error */
syntaxError(NAV_INSTRUCTIONS, ERROR) :- syntaxError(NAV_INSTRUCTIONS, [], ERROR), !.

result(NAVIGATION_DATA, SYNTAX_ERRORS) :- convlist(syntaxError, NAVIGATION_DATA, ERRORS), sumlist(ERRORS, SYNTAX_ERRORS).

/* required for loadData */
data_line(NAV_INSTRUCTION, LINE) :- string_chars(LINE, NAV_INSTRUCTION).
