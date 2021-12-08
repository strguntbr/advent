member([H|T], H, T).
member([H|T], M, [H|MT]) :- member(T, M, MT).

otherDigits(DIGIT, OTHERS) :- member([0,1,2,3,4,5,6,7,8,9], DIGIT, OTHERS).
differentDigit(DIGIT, OTHER) :- digit(OTHER, _), OTHER \= DIGIT.

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

segmentEnabledForDigit(WIRE, DIGIT) :- digit(DIGIT, WIRES), member(WIRE, WIRES).
expectedWireCount(SEGMENT, COUNT) :- aggregate_all(count, segmentEnabledForDigit(SEGMENT, _), COUNT).

patternWithWire(PATTERN, WIRE) :- patterns(PATTERNS), member(PATTERN, PATTERNS), member(WIRE, PATTERN).
countWire(WIRE, COUNT) :- aggregate_all(count, patternWithWire(_, WIRE), COUNT).

wiringPossible(WIRE, SEGMENT) :- countWire(WIRE, C), expectedWireCount(SEGMENT, C).

wiringsPossible(WIRES, SEGMENTS) :- length(WIRES, LENGTH), length(SEGMENTS, LENGTH), wiringsPossible_(WIRES, SEGMENTS).
wiringsPossible_([], _) :- !.
wiringsPossible_(WIRES, SEGMENTS) :-
  member(WIRES, WIRE, OTHER_WIRES), member(SEGMENTS, SEGMENT, OTHER_SEGMENTS),
  wiringPossible(WIRE, SEGMENT), wiringsPossible_(OTHER_WIRES, OTHER_SEGMENTS), !.

canBeDigit(DIGIT, WIRES) :- digit(DIGIT, ENABLED_SEGMENTS), wiringsPossible(WIRES, ENABLED_SEGMENTS).
isDigit(DIGIT, WIRES) :- canBeDigit(DIGIT, WIRES),
  forall(differentDigit(DIGIT, OTHER_DIGIT), not(canBeDigit(OTHER_DIGIT, WIRES))), !.

isEasyDigit(WIRES) :- member(DIGIT, [1,4,7,8]), isDigit(DIGIT, WIRES), !.

countEasyDigits(data{patterns: PATTERNS, display: DISPLAY}, COUNT) :-
  retractall(patterns(_)), assert(patterns(PATTERNS)),
  include(isEasyDigit, DISPLAY, EASY), length(EASY, COUNT).
countAllEasyDigits(DATA, COUNT) :- maplist(countEasyDigits, DATA, COUNTS), sumlist(COUNTS, COUNT).

result(DATA, COUNT) :- countAllEasyDigits(DATA, COUNT).

day(8). testResult(26). solve :- ['lib/solve.prolog'], printResult.

/* required for loadData */
data_line(data{patterns: ALL, display: DISPLAY}, LINE) :-  
  split_string(LINE, "|", " ", [ALL_STR, DISPLAY_STR]),
  string_patterns(ALL_STR, ALL),
  string_patterns(DISPLAY_STR, DISPLAY).

string_patterns(STRING, PATTERNS) :-
  split_string(STRING, " ", "", STRINGS),
  maplist(string_wires, STRINGS, PATTERNS).
string_wires(STRING, PATTERN) :- string_chars(STRING, PATTERN).