row(Row, Matrix) :- member(Row, Matrix).
nthRow1(Index, Matrix, Row) :- nth1(Index, Matrix, Row).
nthRow0(Index, Matrix, Row) :- nth0(Index, Matrix, Row).

col(Col, Matrix) :- nthCol1(_, Matrix, Col).
nthCol1(Index, Matrix, Col) :-
  [Row1|_]=Matrix, length(Row1, Length), between(1, Length, Index),
  maplist([Row,Number] >> nth1(Index, Row, Number), Matrix, Col).
nthCol0(Index, Matrix, Col) :- nthCol1(Index1, Matrix, Col), Index =:= Index1 - 1.