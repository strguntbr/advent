hasInvalidField([H|_]) :- not(fieldValid(_, H)), !.
hasInvalidField([_|T]) :- hasInvalidField(T).
validNearbyTicket(Ticket) :- nearbyTicket(Ticket), not(hasInvalidField(Ticket)).

fieldAtPosValid([H|_], 0, Field) :- !, fieldValid(Field, H).
fieldAtPosValid([_|T], Pos, Field) :- plus(NextPos, 1, Pos), fieldAtPosValid(T, NextPos, Field).
invalidFieldForPos(Ticket, Pos, Field) :- validNearbyTicket(Ticket), not(fieldAtPosValid(Ticket, Pos, Field)).
fieldIsValidForPos(Field, Pos) :- not(invalidFieldForPos(_, Pos, Field)).

findValidFieldsForPos([], _, []).
findValidFieldsForPos([H|T], Pos, [H|ValidT]) :- fieldIsValidForPos(H, Pos), !, findValidFieldsForPos(T, Pos, ValidT).
findValidFieldsForPos([_|T], Pos, ValidT) :- findValidFieldsForPos(T, Pos, ValidT).
findValidFieldsForPos(Pos, Fields) :- availableFields(AllFields), findValidFieldsForPos(AllFields, Pos, Fields).

findValidFieldsForAllPos([], _, []).
findValidFieldsForAllPos([_|T], Pos, [ValidFields|ValidFieldsT]) :- findValidFieldsForPos(Pos, ValidFields), plus(Pos, 1, PosNext), findValidFieldsForAllPos(T, PosNext, ValidFieldsT).
findValidFieldsForAllPos(Fields) :- availableFields(AllFields), findValidFieldsForAllPos(AllFields, 0, Fields).

deleteField(_, [], []).
deleteField(Field, [[Hh|Ht]|T], [Hr|Tr]) :- delete([Hh|Ht], Field, Hr), deleteField(Field, T, Tr).
combine([], []).
combine([FieldsH|FieldsT], [Field|CombinationT]) :-  member(Field, FieldsH), deleteField(Field, FieldsT, OtherFields), combine(OtherFields, CombinationT).

findFieldOrder(FieldOrder) :- findValidFieldsForAllPos(Fields), combine(Fields, FieldOrder).

availableFields(AllFields) :- findall(Field, field(Field), AllFields).
field(Field) :- fieldValid(Field, _).
departureField(Field) :- field(Field), sub_string(Field, 0, _, _, "departure").

departureFieldValues([], _, []).
departureFieldValues([FirstVal|OtherVals], [FirstField|OtherFields], [FirstVal|T]) :- departureField(FirstField), !, departureFieldValues(OtherVals, OtherFields, T).
departureFieldValues([_|OtherVals], [_|OtherFields], T) :- departureFieldValues(OtherVals, OtherFields, T).

listProduct([], 1).
listProduct([H|T], P) :- listProduct(T, Pt), P is H*Pt.

solve(File) :-
  loadData(_, File),
  myTicket(MyTicket),
  findFieldOrder(FieldOrder),
  departureFieldValues(MyTicket, FieldOrder, FieldValues),
  listProduct(FieldValues, Product),
  write(Product).
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