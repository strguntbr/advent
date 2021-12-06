day(25).

crack(_, PublicKey, 0, PublicKey) :- !.
crack(SubjectNumber, Value, LoopSize, PublicKey) :-
  NextValue is Value*SubjectNumber mod 20201227,
  crack(SubjectNumber, NextValue, NextLoopSize, PublicKey),
  LoopSize is NextLoopSize+1.
crack(SubjectNumber, LoopSize, PublicKey) :- crack(SubjectNumber, 1, LoopSize, PublicKey).

transform(_, Value, 0, Value) :- !.
transform(StartValue, Value, LoopSize, Result) :-
  NextLoopSize is LoopSize-1,
  transform(StartValue, Value, NextLoopSize, NextResult),
  Result is NextResult*StartValue mod 20201227.
transform(StartValue, LoopSize, Result) :- transform(StartValue, 1, LoopSize, Result).

solve(File) :-
  loadData([CardPK, DoorPK], File),
  crack(7, _, CardPK), crack(7, DoorLS, DoorPK),
  transform(CardPK, DoorLS, Result),
  !, write(Result).
solveTest :- ['lib/loadData.prolog'], day(DAY), solveTestDay(DAY).
solveTest(N) :- ['lib/loadData.prolog'], day(DAY), solveTestDay(DAY, N).
solve :- ['lib/loadData.prolog'], day(DAY), solveDay(DAY).

/* required for loadData */
data_line(PublicKey, Line) :- number_string(PublicKey, Line)
.