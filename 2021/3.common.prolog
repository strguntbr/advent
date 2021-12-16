day(3). solve :- ['lib/solve.prolog'], printResult.

:- include('lib/matrix.prolog').
:- include('lib/binary.prolog').

mostCommonBit(BitList, MostCommonBit) :-
  aggregate_all(count, member(1, BitList), Count1), length(BitList, Length),
  ( Count1 >=Length / 2 -> MostCommonBit = 1 ; MostCommonBit = 0 ).
leastCommonBit(BitList, LeastCommonBit) :-
  aggregate_all(count, member(1, BitList), Count1), length(BitList, Length),
  ( Count1 >= Length / 2 -> LeastCommonBit = 0 ; LeastCommonBit = 1 ).

/* required for loadData */
data_line(Digits, Line) :- string_chars(Line, Chars), digits_chars(Digits, Chars).
digits_chars(Digits, Chars) :- maplist([D, C] >> (atom_string(C, S), number_string(D, S)), Digits, Chars).
