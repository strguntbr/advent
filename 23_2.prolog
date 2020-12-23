day(23).

distance(Cup, 0, Cup) :- !.
distance(StartCup, Distance, EndCup) :- cup(StartCup, NextCup), NextDistance is Distance-1, distance(NextCup, NextDistance, EndCup).

pickedCup(Cup, Cup) :- !.
pickedCup(PickedCupStart, Cup) :- cup(PickedCupStart, NextPickedCup), pickedCup(NextPickedCup, Cup).

pickCups(CurCup, [StartCup, EndCup]) :-
  cup(CurCup, StartCup),
  distance(StartCup, 2, EndCup),
  cup(EndCup, NextCup),
  retractall(cup(CurCup, StartCup)),
  retractall(cup(EndCup, NextCup)),
  assertz(cup(CurCup, NextCup)).

findDestinationCup(Candidate, [PickedCupStart, _], Candidate) :- Candidate > 0, not(pickedCup(PickedCupStart, Candidate)), !.
findDestinationCup(Candidate, PickedCups, DestinationCup) :- Candidate > 0, NextCandidate is Candidate-1, findDestinationCup(NextCandidate, PickedCups, DestinationCup), !.
findDestinationCup(Candidate, PickedCups, DestinationCup) :- Candidate = 0, size(NextCandidate), findDestinationCup(NextCandidate, PickedCups, DestinationCup), !.

placeCups(DestinationCup, [StartCup, EndCup]) :-
  cup(DestinationCup, NextCup),
  retractall(cup(DestinationCup, NextCup)),
  assertz(cup(DestinationCup, StartCup)),
  assertz(cup(EndCup, NextCup)).

moveCurCup(CurCup, NextCup) :- cup(CurCup, NextCup).

playRound(CurCup, NextCup) :-
  pickCups(CurCup, PickedCups),
  DestinationCandidate is CurCup - 1, findDestinationCup(DestinationCandidate, PickedCups, DestinationCup),
  placeCups(DestinationCup, PickedCups),
  moveCurCup(CurCup, NextCup).

play(_, 0) :- !.
play(StartCup, Rounds) :- Rounds > 0, NextRounds is Rounds-1, playRound(StartCup, NextCup), play(NextCup, NextRounds).

result(Result) :- cup(1, C1), cup(C1, C2), Result is C1 * C2.

createSequence(From, To, []) :- plus(To, 1, From), !.
createSequence(To, To, [To]) :- !.
createSequence(From, To, [From|SubSequence]) :- From < To, plus(From, 1, NextFrom), createSequence(NextFrom, To, SubSequence).

linkCups(StartCup, [Cup|[]]) :- !, assertz(cup(Cup, StartCup)).
linkCups(StartCup, [Cup|[Next|Rest]]) :- assertz(cup(Cup, Next)), linkCups(StartCup, [Next|Rest]).

createStartingCups(InitialCups, Count) :-
  retractall(cup(_, _)),
  length(InitialCups, L), plus(L, 1, Start),
  createSequence(Start, Count, Seq),
  append(InitialCups, Seq, StartingCups),
  InitialCups = [StartCup|_],
  linkCups(StartCup, StartingCups).

solve(File) :-
  Size = 1_000_000, Rounds = 10_000_000,
  assertz(size(Size)),
  loadData([InitialCups], File),
  createStartingCups(InitialCups, Size),
  InitialCups = [StartCup|_],
  play(StartCup, Rounds),
  result(Result),
  !, write(Result).
solveTest :- ['lib/loadData.prolog'], day(DAY), solveTestDay(DAY).
solveTest(N) :- ['lib/loadData.prolog'], day(DAY), solveTestDay(DAY, N).
solve :- ['lib/loadData.prolog'], day(DAY), solveDay(DAY).

/* required for loadData */
data_line(Cups, Line) :- string_chars(Line, CupChars), atoms_numbers(CupChars, Cups).

atoms_numbers([], []).
atoms_numbers([Ah|At], [Nh|Nt]) :- atom_number(Ah, Nh), atoms_numbers(At, Nt).