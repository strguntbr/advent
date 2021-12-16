:- include('3.common.prolog'). testResult(198).

result(Report, PowerConsumption) :-
  Report = [First|_], length(First, Length), generateIndexList(Length, Indices),
  maplist([I, ΓBit, ΕBit] >> (nthCol1(I, Report, Col), mostCommonBit(Col, ΓBit), leastCommonBit(Col, ΕBit)), Indices, BinaryΓ, BinaryΕ),
  binary_value(BinaryΓ, Γ), binary_value(BinaryΕ, Ε),
  PowerConsumption is Γ * Ε.

generateIndexList(0, []) :- !.
generateIndexList(Length, List) :- Length > 0, NextLength is Length - 1, generateIndexList(NextLength, NextList), append(NextList, [Length], List).
