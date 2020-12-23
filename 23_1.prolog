day(23).

smallerBigger([], _, [], []).
smallerBigger([H|T], Pivot, [H|Smaller], Bigger) :- H < Pivot, smallerBigger(T, Pivot, Smaller, Bigger).
smallerBigger([H|T], Pivot, Smaller, [H|Bigger]) :- H > Pivot, smallerBigger(T, Pivot, Smaller, Bigger).

rotated(L, 0, L) :- !.
rotated([H|T], Count, Rotated) :- Count > 0, append(T, [H], Temp), plus(NextCount, 1, Count), rotated(Temp, NextCount, Rotated).

findDestinationCup(Smaller, _, DestinationCup) :- max_member(DestinationCup, Smaller).
findDestinationCup([], Bigger, DestinationCup) :- max_member(DestinationCup, Bigger).
findDestinationCup([Current|OtherCups], DestinationCup) :- smallerBigger(OtherCups, Current, Smaller, Bigger), findDestinationCup(Smaller, Bigger, DestinationCup), !.

pickCups([Current|Cups], PickedCups, [Current|OtherCups]) :- length(PickedCups, 3), append(PickedCups, OtherCups, Cups).

insertAfter([Pivot|T], Pivot, List2, Result) :- !, append([Pivot|List2], T, Result).
insertAfter([H|T], Pivot, List2, [H|TResult]) :- insertAfter(T, Pivot, List2, TResult).

playRound(InputCups, OutputCups) :-
  pickCups(InputCups, PickedCups, RemainingCups),
  findDestinationCup(RemainingCups, DestinationCup),
  insertAfter(RemainingCups, DestinationCup, PickedCups, NewCups),
  rotated(NewCups, 1, OutputCups).

play(Cups, 0, Cups).
play(InputCups, Rounds, OutputCups) :- 
  Rounds > 0,
  plus(NextRounds, 1, Rounds),
  playRound(InputCups, CupsAfterRound),
  play(CupsAfterRound, NextRounds, OutputCups).

result(Cups, Result) :-
  length(Cups, L),
  R=[1|Result],
  length(R, L),
  between(0, L, C),
  rotated(Cups, C, R).

writeResult([]).
writeResult([H|T]) :- write(H), writeResult(T).

solve(File) :-
  loadData([StartingCups], File),
  play(StartingCups, 100, FinalCups),
  result(FinalCups, Result),
  !, writeResult(Result).
solveTest :- ['lib/loadData.prolog'], day(DAY), solveTestDay(DAY).
solveTest(N) :- ['lib/loadData.prolog'], day(DAY), solveTestDay(DAY, N).
solve :- ['lib/loadData.prolog'], day(DAY), solveDay(DAY).

/* required for loadData */
data_line(Cups, Line) :- string_chars(Line, CupChars), atoms_numbers(CupChars, Cups).

atoms_numbers([], []).
atoms_numbers([Ah|At], [Nh|Nt]) :- atom_number(Ah, Nh), atoms_numbers(At, Nt).