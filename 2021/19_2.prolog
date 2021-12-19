:- include('19.common.prolog'). testResult(3621).

result(Input, Result) :-
  alignAllScans(Input, AlignedScans),
  aggregate_all(max(D), (select2(Scan1, Scan2, AlignedScans), manhatten_distance(Scan1, Scan2, D)), Result).

manhatten_distance(Scan1, Scan2, Distance) :- [X1, Y1, Z1] = Scan1.s, [X2, Y2, Z2] = Scan2.s, Distance is abs(X1-X2) + abs(Y1-Y2) + abs(Z1-Z2).
