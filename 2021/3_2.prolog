:- include('3.common.prolog'). testResult(230).

result(Report, LifeSupportRating) :-
  oxygenGenerator(Report, 0, OxygenGeneratorRating),
  co2Scrubber(Report, 0, Co2ScrubberRating),
  LifeSupportRating is OxygenGeneratorRating * Co2ScrubberRating.

oxygenGenerator([BinaryRating], _, Rating) :- !, binary_value(BinaryRating, Rating).
oxygenGenerator(Report, Index, Rating) :-
  nthCol0(Index, Report, Col), mostCommonBit(Col, MCB),
  findall(Number, (member(Number, Report), nth0(Index, Number, MCB)), CondensedReport),
  NextIndex is Index + 1, oxygenGenerator(CondensedReport, NextIndex, Rating).

co2Scrubber([BinaryRating], _, Rating) :- !, binary_value(BinaryRating, Rating).
co2Scrubber(Report, Index, Rating) :-
  nthCol0(Index, Report, Col), leastCommonBit(Col, LCB),
  findall(Number, (member(Number, Report), nth0(Index, Number, LCB)), CondensedReport),
  NextIndex is Index + 1, co2Scrubber(CondensedReport, NextIndex, Rating).
