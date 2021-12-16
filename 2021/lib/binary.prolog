binary_to_hex(Binary, Hex) :- length(Binary, L), (
  (L mod 4 =:= 0, L > 0) -> binary_to_hexchars(Binary, HexChars), string_chars(Hex, HexChars)
  ; binary_to_hex([0|Binary], Hex)
).

binary_to_hexchars([B3, B2, B1, B0], [HexChar]) :- hexchar_binary(HexChar, [B3, B2, B1, B0]).
binary_to_hexchars([B3, B2, B1, B0 | BRest], [H0 | HRest]) :- hexchar_binary(H0, [B3, B2, B1, B0]), binary_to_hexchars(BRest, HRest).

binary_value(B, V) :- reverse(B, RB), binary_value_(RB, V).
binary_value_([], 0).
binary_value_([H|T], V) :-  binary_value_(T, VR), V is VR * 2 + H.

hexchar_binary('0', [0, 0, 0, 0]).
hexchar_binary('1', [0, 0, 0, 1]).
hexchar_binary('2', [0, 0, 1, 0]).
hexchar_binary('3', [0, 0, 1, 1]).
hexchar_binary('4', [0, 1, 0, 0]).
hexchar_binary('5', [0, 1, 0, 1]).
hexchar_binary('6', [0, 1, 1, 0]).
hexchar_binary('7', [0, 1, 1, 1]).
hexchar_binary('8', [1, 0, 0, 0]).
hexchar_binary('9', [1, 0, 0, 1]).
hexchar_binary('A', [1, 0, 1, 0]).
hexchar_binary('B', [1, 0, 1, 1]).
hexchar_binary('C', [1, 1, 0, 0]).
hexchar_binary('D', [1, 1, 0, 1]).
hexchar_binary('E', [1, 1, 1, 0]).
hexchar_binary('F', [1, 1, 1, 1]).
