day(8). testResult(26). solve :- ['lib/solve.prolog'], printResult.

result(Data, Count) :- initExpectedWireCounts, aggregate_all(sum(C), (member(DisplaySpec, Data), countEasyDigits(DisplaySpec, C)), Count).

digit(0, ['a', 'b', 'c', 'e', 'f', 'g']).
digit(1, ['c', 'f']).
digit(2, ['a', 'c', 'd', 'e', 'g']).
digit(3, ['a', 'c', 'd', 'f', 'g']).
digit(4, ['b', 'c', 'd', 'f']).
digit(5, ['a', 'b', 'd', 'f', 'g']).
digit(6, ['a', 'b', 'd', 'e', 'f', 'g']).
digit(7, ['a', 'c', 'f']).
digit(8, ['a', 'b', 'c', 'd', 'e', 'f', 'g']).
digit(9, ['a', 'b', 'c', 'd', 'f', 'g']).

initExpectedWireCounts :- retractall(expectedWireCount(_, _)), digit(8, Segments), forall(member(Segment, Segments), initExpectedWireCount(Segment)).
initExpectedWireCount(Segment) :- aggregate_all(count, segmentEnabledForDigit(Segment, _), Count), assert(expectedWireCount(Segment, Count)).
segmentEnabledForDigit(Wire, Digit) :- digit(Digit, Wires), member(Wire, Wires).

member([H|T], H, T).
member([H|T], M, [H|MT]) :- member(T, M, MT).

wiringPossible(Wire, Segment) :- wireCount(Wire, C), expectedWireCount(Segment, C).
wiringsPossible(Wires, Segments) :- length(Wires, Length), length(Segments, Length), wiringsPossible_(Wires, Segments).
wiringsPossible_([], _) :- !.
wiringsPossible_(Wires, Segments) :-
  member(Wires, Wire, OtherWires), member(Segments, Segment, OtherSegments),
  wiringPossible(Wire, Segment), wiringsPossible_(OtherWires, OtherSegments), !.

canBeDigit(Digit, Wires) :- digit(Digit, EnabledSegments), wiringsPossible(Wires, EnabledSegments).
isDigit(Digit, Wires) :- canBeDigit(Digit, Wires), forall((digit(OtherDigit, _), OtherDigit \= Digit), not(canBeDigit(OtherDigit, Wires))), !.

isEasyDigit(Wires) :- member(Digit, [1,4,7,8]), isDigit(Digit, Wires), !.
countEasyDigits(data{patterns: Patterns, display: Display}, Count) :- initWireCounts(Patterns), aggregate_all(count, (member(Digit, Display), isEasyDigit(Digit)), Count).

initWireCounts(Patterns) :- digit(8, Wires), forall(member(Wire, Wires), initWireCount(Wire, Patterns)).
initWireCount(Wire, Patterns) :-
  aggregate_all(count, (member(Pattern, Patterns), member(Wire, Pattern)), Count),
  retractall(wireCount(Wire, _)), assert(wireCount(Wire, Count)).

/* required for loadData */
data_line(data{patterns: All, display: Display}, Line) :-  
  split_string(Line, "|", " ", [AllStr, DisplayStr]),
  string_patterns(AllStr, All),
  string_patterns(DisplayStr, Display).

string_patterns(String, Patterns) :-
  split_string(String, " ", "", Strings),
  maplist(string_chars, Strings, Patterns).
