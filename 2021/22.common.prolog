:- include('lib/solve.prolog'). day(22).

/* required for loadData */
data_line(op{o: Op, c: [XRange, YRange, ZRange]}, Line) :-
  string_operation(Line, Op, RangesStr), split_string(RangesStr, ',', '', [XStr, YStr, ZStr]),
  string_concat("x=", XRangeStr, XStr), string_range(XRangeStr, XRange),
  string_concat("y=", YRangeStr, YStr), string_range(YRangeStr, YRange),
  string_concat("z=", ZRangeStr, ZStr), string_range(ZRangeStr, ZRange).

string_operation(String, 'on', RangesStr) :- string_concat("on ", RangesStr, String).
string_operation(String, 'off', RangesStr) :- string_concat("off ", RangesStr, String).
string_range(String, [Start, End]) :-
  split_string(String, '.', '', [StartStr, "", EndStr]),
  number_string(Start, StartStr), number_string(End, EndStr).