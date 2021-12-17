:- include('lib/solve.prolog'). day(16).

:- include('lib/binary.prolog').

result([Bits], Result) :- parsePacket(Bits, Result, _).

parsePacket([V2, V1, V0, T2, T1, T0 | C], Content, RemainingBits) :-
  binary_value([V2, V1, V0], Version), binary_value([T2, T1, T0], Type),
  parseContent(Version, Type, C, Content, RemainingBits).

parseContent(Version, 4, Bits, Result, RemainingBits) :- !,
  parseLiteral(Bits, LiteralBits, RemainingBits), binary_value(LiteralBits, Literal),
  eval(Version, 4, Literal, Result).
parseContent(Version, Type, [0|Bits], Result, RemainingBits) :-
  length(LengthField, 15), append(LengthField, BitsWoLengthField, Bits), binary_value(LengthField, Length),
  length(SubPacketBits, Length), append(SubPacketBits, RemainingBits, BitsWoLengthField),
  parsePackets(SubPacketBits, SubPackets, []),
  eval(Version, Type, SubPackets, Result).
parseContent(Version, Type, [1|Bits], Result, RemainingBits) :-
  length(LengthField, 11), append(LengthField, SubPacketBits, Bits), binary_value(LengthField, Length),
  length(SubPackets, Length), parsePackets(SubPacketBits, SubPackets, RemainingBits),
  eval(Version, Type, SubPackets, Result).

parseLiteral([0, B3, B2, B1, B0 | RemainingBits], [B3, B2, B1, B0], RemainingBits).
parseLiteral([1, B3, B2, B1, B0 | NextBits], [B3, B2, B1, B0 | NextLiteral], RemainingBits) :- parseLiteral(NextBits, NextLiteral, RemainingBits).

parsePackets(Bits, [Result|NextResults], RemainingBits) :- parsePacket(Bits, Result, NextBits), parsePackets(NextBits, NextResults, RemainingBits), !.
parsePackets(RemainingBits, [], RemainingBits).

/* required for loadData */
data_line(Bits, Line) :- string_chars(Line, Hex), maplist(hexchar_binary, Hex, Binary), append(Binary, Bits).
