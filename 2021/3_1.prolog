binary_number([], 0).
binary_number([H|T], NUMBER) :- binary_number(T, NUMBERr), NUMBER is NUMBERr * 2 + H.

binAdd_([], [], []).
binAdd_([Ah|At], [Bh|Bt], [Sh|St]) :- Sh is Ah + Bh, binAdd_(At, Bt, St).
binAdd([H], H, 1) :- !.
binAdd([H|T], S, C) :- binAdd(T, Tn, Cn), C is Cn + 1, binAdd_(H, Tn, S).

mostCommon_([], _, []).
mostCommon_([H|T], C, [1|Tr]) :- H*2 > C, !, mostCommon_(T, C, Tr).
mostCommon_([_|T], C, [0|Tr]) :- mostCommon_(T, C, Tr).
mostCommon(DATA, MCD) :- binAdd(DATA, SUM, C), mostCommon_(SUM, C, MCD).

invertCommon([], []).
invertCommon([0|T], [1|Ti]) :- invertCommon(T, Ti).
invertCommon([1|T], [0|Ti]) :- invertCommon(T, Ti).

result(DATA, RESULT) :- mostCommon(DATA, MCD), invertCommon(MCD, LCD), binary_number(MCD, GAMMA), binary_number(LCD, EPSILON), RESULT is GAMMA * EPSILON.

day(3). testResult(198). solve :- ['lib/solve.prolog'], printResult.

/* required for loadData */
data_line(DIGITS, LINE) :-
    string_chars(LINE, CHARS), digits_chars(REV_DIGITS, CHARS), reverse(REV_DIGITS, DIGITS).
digits_chars([], []).
digits_chars([Hd|Td], [Hc|Tc]) :- atom_string(Hc, Hs), number_string(Hd, Hs), digits_chars(Td, Tc).
