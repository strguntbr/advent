binary_number([], 0).
binary_number([H|T], NUMBER) :- binary_number(T, NUMBERr), NUMBER is NUMBERr * 2 + H.

binAdd_([], [], []).
binAdd_([Ah|At], [Bh|Bt], [Sh|St]) :- Sh is Ah + Bh, binAdd_(At, Bt, St).
binAdd([H], H, 1) :- !.
binAdd([H|T], S, C) :- binAdd(T, Tn, Cn), C is Cn + 1, binAdd_(H, Tn, S).

mostCommon_([], _, []).
mostCommon_([H|T], C, [1|Tr]) :- H*2 >= C, !, mostCommon_(T, C, Tr).
mostCommon_([_|T], C, [0|Tr]) :- mostCommon_(T, C, Tr).
mostCommon(DATA, MCD) :- binAdd(DATA, SUM, C), mostCommon_(SUM, C, MCD).

leastCommon_([], _, []).
leastCommon_([H|T], C, [1|Tr]) :- H*2 < C, !, leastCommon_(T, C, Tr).
leastCommon_([_|T], C, [0|Tr]) :- leastCommon_(T, C, Tr).
leastCommon(DATA, LCD) :- binAdd(DATA, SUM, C), leastCommon_(SUM, C, LCD).

matches([V|_], 0, V) :- !.
matches([_|T], P, V) :- P > 0, !, Pn is P - 1, matches(T, Pn, V).

keepOnly([], _, _, []).
keepOnly([H|T], P, V, [H|Tn]) :- matches(H, P, V), !, keepOnly(T, P, V, Tn).
keepOnly([_|T], P, V, Tn) :- keepOnly(T, P, V, Tn).

keepOnlyMostCommon(L, P, R) :- mostCommon(L, MC), nth0(P, MC, V), keepOnly(L, P, V, R1), length(R1, X), X > 1, !, P1 is P+1, keepOnlyMostCommon(R1, P1, R).
keepOnlyMostCommon(L, P, R) :- mostCommon(L, MC), nth0(P, MC, V), keepOnly(L, P, V, R), length(R, 1).

keepOnlyLeastCommon(L, P, R) :- leastCommon(L, MC), nth0(P, MC, V), keepOnly(L, P, V, R1), length(R1, X), X > 1, !, P1 is P+1, keepOnlyLeastCommon(R1, P1, R).
keepOnlyLeastCommon(L, P, R) :- leastCommon(L, MC), nth0(P, MC, V), keepOnly(L, P, V, R), length(R, 1).

result(DATA, RESULT) :- keepOnlyMostCommon(DATA, 0, [MCD]), keepOnlyLeastCommon(DATA, 0, [LCD]), reverse(MCD, RMCD), reverse(LCD, RLCD), binary_number(RMCD, OXYGEN), binary_number(RLCD, CO2), RESULT is OXYGEN * CO2.

day(3). testResult(230). solve :- ['lib/solve.prolog'], printResult.

/* required for loadData */
data_line(DIGITS, LINE) :-
    string_chars(LINE, CHARS), digits_chars(DIGITS, CHARS).
digits_chars([], []).
digits_chars([Hd|Td], [Hc|Tc]) :- atom_string(Hc, Hs), number_string(Hd, Hs), digits_chars(Td, Tc).
