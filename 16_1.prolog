errorValue(FieldValue, 0) :- fieldValid(_, FieldValue), !.
errorValue(FieldValue, FieldValue).
errorScanningRate([], 0).
errorScanningRate([H|T], Value) :- errorScanningRate(T, TValue), errorValue(H, HValue), plus(HValue, TValue, Value).

nearbyErrorScanningRate(Ticket, Value) :- nearbyTicket(Ticket), errorScanningRate(Ticket, Value).

solve(File) :-
  loadData(_, File),
  aggregate_all(sum(ErrorValue), nearbyErrorScanningRate(_, ErrorValue), Sum),
  write(Sum).
solveTest :- ['lib/loadData.prolog'], solveTestDay(16).
solveTest(N) :- ['lib/loadData.prolog'], solveTestDay(16, N).
solve :- ['lib/loadData.prolog'], solveDay(16).

/* required for loadData */
data_line([], "") :- !.
data_line([], Line) :- parseFieldDefinition(Line).
data_line([], Line) :- startTicketSegment(Line).
data_line([], Line) :- startNearbySegment(Line).
data_line([], Line) :- parseTicket(Line).

startTicketSegment("your ticket:") :- assertz(inSegment("ticket")).
startNearbySegment("nearby tickets:") :- assertz(inSegment("nearby")).

parseTicket(Line) :- split_string(Line, ",", "", FieldStrs), numbers_strings(Fields, FieldStrs), createTicket(Fields).
createTicket(Fields) :- inSegment("nearby"), !, assertz(nearbyTicket(Fields)).
createTicket(Fields) :- inSegment("ticket"), assertz(myTicket(Fields)).

numbers_strings([] ,[]).
numbers_strings([Nh|Nt], [Sh|St]) :- number_string(Nh, Sh), numbers_strings(Nt, St).

convert([], []).
convert([FirstRangeStr|OtherRangeStrs], [range{min: Min, max: Max}|OtherRanges]) :-
  split_string(FirstRangeStr, "-", "", [MinStr, MaxStr]),
  number_string(Min, MinStr), number_string(Max, MaxStr),
  convert(OtherRangeStrs, OtherRanges).

inRange(V, [range{min: Min, max: Max}|_]) :- between(Min, Max, V), !.
inRange(V, [_|OtherRanges]) :- inRange(V, OtherRanges).

parseFieldDefinition(Line) :-
  split_string(Line, ":", "", [Name, RawRanges]), split_string(RawRanges, "o", "r ", RangeStrList), convert(RangeStrList, Ranges),
  assertz(fieldValid(Name, Value) :- inRange(Value, Ranges)).