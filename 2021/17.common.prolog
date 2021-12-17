:- include('lib/solve.prolog'). day(17).

/* required for loadData */
data_line(area{minX: XMin, maxX: XMax, minY: YMin, maxY: YMax}, Line) :-
  string_concat("target area: x=", T1, Line),
  string_concat(XMinStr, T2, T1),
  string_concat("..", T3, T2),
  string_concat(XMaxStr, T4, T3),
  string_concat(", y=", T5, T4),
  string_concat(YMinStr, T6, T5),
  string_concat("..", YMaxStr, T6),
  maplist(number_string, [XMin, XMax, YMin, YMax], [XMinStr, XMaxStr, YMinStr, YMaxStr]).
