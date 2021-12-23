:- include('lib/solve.prolog'). day(23).

result(Rooms, MinimumEnergy) :-
  initRooms(Rooms, A, B, C, D),
  setCurMinimum(1000000000), StartingBurrow = burrow{rA: A, rB: B, rC: C, rD: D, h1: [], h2: [], h3: [], h4: [], h5: [], h6: [], h7: []},
  aggregate_all(min(Energy), play(StartingBurrow, 0, Energy), MinimumEnergy).

setCurMinimum(M) :- retractall(getCurMinimum(_)), assert(getCurMinimum(M)).

play(burrow{rA: A, rB: B, rC: C, rD: D, h1: [], h2: [], h3: [], h4: [], h5: [], h6: [], h7: []}, Energy, Energy) :-
  canMoveIn(A, 'A'), canMoveIn(B, 'B'), canMoveIn(C, 'C'), canMoveIn(D, 'D'),
  (isAnsiXterm -> cursorPosition(Pos), format(" ~w~n", [Energy]), Right is Pos - 1, moveCursor(1, 'up'), moveCursor(Right, 'right'), flush_output ; true),
  setCurMinimum(Energy).
play(Burrow, Energy, EnergyResult) :-
  move(Burrow, BurrowForHoming, EnergyForMove), homeAll(BurrowForHoming, NextBurrow, HomingEnergy),
  NextEnergy is Energy + EnergyForMove + HomingEnergy, isBranchFeasable(NextBurrow, NextEnergy),
  play(NextBurrow, NextEnergy, EnergyResult).

isBranchFeasable(Burrow, EnergyRequiredSoFar) :-
  minimumEnergyRequired(Burrow, MinimumEnergyRequired), getCurMinimum(CurMinimum), EnergyRequiredSoFar+MinimumEnergyRequired < CurMinimum.

minimumEnergyRequired(burrow{rA:A, rB:B, rC:C, rD:D, h1:H1, h2:H2, h3:H3, h4:H4, h5:H5, h6:H6, h7:H7}, Min) :-
  aggregate_all(count, member('A', B), AinB),
  aggregate_all(count, member('A', C), AinC),
  aggregate_all(count, member('A', D), AinD),
  aggregate_all(count, member('B', A), BinA),
  aggregate_all(count, member('B', C), BinC),
  aggregate_all(count, member('B', D), BinD),
  aggregate_all(count, member('C', A), CinA),
  aggregate_all(count, member('C', B), CinB),
  aggregate_all(count, member('C', D), CinD),
  aggregate_all(count, member('D', A), DinA),
  aggregate_all(count, member('D', B), DinB),
  aggregate_all(count, member('D', C), DinC),
  (H1='A' -> H1E=3 ; H1='B' -> H1E=50 ; H1='C' -> H1E=700 ; H1='D' -> H1E=9000 ; H1E=0),
  (H2='A' -> H2E=2 ; H2='B' -> H2E=40 ; H2='C' -> H2E=600 ; H2='D' -> H2E=8000 ; H2E=0),
  (H3='A' -> H3E=2 ; H3='B' -> H3E=20 ; H3='C' -> H3E=400 ; H3='D' -> H3E=6000 ; H3E=0),
  (H4='A' -> H4E=4 ; H4='B' -> H4E=20 ; H4='C' -> H4E=200 ; H4='D' -> H4E=4000 ; H4E=0),
  (H5='A' -> H5E=6 ; H5='B' -> H5E=40 ; H5='C' -> H5E=200 ; H5='D' -> H5E=2000 ; H5E=0),
  (H6='A' -> H6E=8 ; H6='B' -> H6E=60 ; H6='C' -> H6E=400 ; H6='D' -> H6E=2000 ; H6E=0),
  (H7='A' -> H7E=9 ; H7='B' -> H7E=70 ; H7='C' -> H7E=500 ; H7='D' -> H7E=3000 ; H7E=0),
  Min is AinB*4+AinC*6+AinD*8 + BinA*40+BinC*40+BinD*60 + CinA*600+CinB*400+CinD*400 + DinA*8000+DinB*6000+DinC*4000 + H1E+H2E+H3E+H4E+H5E+H6E+H7E.

homeAll(Burrow, HomedBurrow, Energy) :-
  home(Burrow, NextBurrow, E1), !,
  homeAll(NextBurrow, HomedBurrow, E2),
  Energy is E1+E2.
homeAll(Burrow, Burrow, 0).

home(burrow{rA: RA,       rB: RB, rC: RC, rD: RD, h1: 'A', h2: [], h3: H3, h4: H4, h5: H5, h6: H6, h7: H7},
     burrow{rA: ['A'|RA], rB: RB, rC: RC, rD: RD, h1: [],  h2: [], h3: H3, h4: H4, h5: H5, h6: H6, h7: H7}, Energy) :- canMoveIn(RA, 'A'), energy('A', RA, 3, Energy).
home(burrow{rA: RA,       rB: RB, rC: RC, rD: RD, h1: H1, h2: 'A', h3: H3, h4: H4, h5: H5, h6: H6, h7: H7},
     burrow{rA: ['A'|RA], rB: RB, rC: RC, rD: RD, h1: H1, h2: [],  h3: H3, h4: H4, h5: H5, h6: H6, h7: H7}, Energy) :- canMoveIn(RA, 'A'), energy('A', RA, 2, Energy).
home(burrow{rA: RA,       rB: RB, rC: RC, rD: RD, h1: H1, h2: H2, h3: 'A', h4: H4, h5: H5, h6: H6, h7: H7},
     burrow{rA: ['A'|RA], rB: RB, rC: RC, rD: RD, h1: H1, h2: H2, h3: [],  h4: H4, h5: H5, h6: H6, h7: H7}, Energy) :- canMoveIn(RA, 'A'), energy('A', RA, 2, Energy).
home(burrow{rA: RA,       rB: RB, rC: RC, rD: RD, h1: H1, h2: H2, h3: [], h4: 'A', h5: H5, h6: H6, h7: H7},
     burrow{rA: ['A'|RA], rB: RB, rC: RC, rD: RD, h1: H1, h2: H2, h3: [], h4: [],  h5: H5, h6: H6, h7: H7}, Energy) :- canMoveIn(RA, 'A'), energy('A', RA, 4, Energy).
home(burrow{rA: RA,       rB: RB, rC: RC, rD: RD, h1: H1, h2: H2, h3: [], h4: [], h5: 'A', h6: H6, h7: H7},
     burrow{rA: ['A'|RA], rB: RB, rC: RC, rD: RD, h1: H1, h2: H2, h3: [], h4: [], h5: [],  h6: H6, h7: H7}, Energy) :- canMoveIn(RA, 'A'), energy('A', RA, 6, Energy).
home(burrow{rA: RA,       rB: RB, rC: RC, rD: RD, h1: H1, h2: H2, h3: [], h4: [], h5: [], h6: 'A', h7: H7},
     burrow{rA: ['A'|RA], rB: RB, rC: RC, rD: RD, h1: H1, h2: H2, h3: [], h4: [], h5: [], h6: [],  h7: H7}, Energy) :- canMoveIn(RA, 'A'), energy('A', RA, 8, Energy).
home(burrow{rA: RA,       rB: RB, rC: RC, rD: RD, h1: H1, h2: H2, h3: [], h4: [], h5: [], h6: [], h7: 'A'},
     burrow{rA: ['A'|RA], rB: RB, rC: RC, rD: RD, h1: H1, h2: H2, h3: [], h4: [], h5: [], h6: [], h7: [] }, Energy) :- canMoveIn(RA, 'A'), energy('A', RA, 9, Energy).

home(burrow{rA: RA, rB: RB,       rC: RC, rD: RD, h1: 'B', h2: [], h3: [], h4: H4, h5: H5, h6: H6, h7: H7},
     burrow{rA: RA, rB: ['B'|RB], rC: RC, rD: RD, h1: [],  h2: [], h3: [], h4: H4, h5: H5, h6: H6, h7: H7}, Energy) :- canMoveIn(RB, 'B'), energy('B', RB, 5, Energy).
home(burrow{rA: RA, rB: RB,       rC: RC, rD: RD, h1: H1, h2: 'B', h3: [], h4: H4, h5: H5, h6: H6, h7: H7},
     burrow{rA: RA, rB: ['B'|RB], rC: RC, rD: RD, h1: H1, h2: [],  h3: [], h4: H4, h5: H5, h6: H6, h7: H7}, Energy) :- canMoveIn(RB, 'B'), energy('B', RB, 4, Energy).
home(burrow{rA: RA, rB: RB,       rC: RC, rD: RD, h1: H1, h2: H2, h3: 'B', h4: H4, h5: H5, h6: H6, h7: H7},
     burrow{rA: RA, rB: ['B'|RB], rC: RC, rD: RD, h1: H1, h2: H2, h3: [],  h4: H4, h5: H5, h6: H6, h7: H7}, Energy) :- canMoveIn(RB, 'B'), energy('B', RB, 2, Energy).
home(burrow{rA: RA, rB: RB,       rC: RC, rD: RD, h1: H1, h2: H2, h3: H3, h4: 'B', h5: H5, h6: H6, h7: H7},
     burrow{rA: RA, rB: ['B'|RB], rC: RC, rD: RD, h1: H1, h2: H2, h3: H3, h4: [],  h5: H5, h6: H6, h7: H7}, Energy) :- canMoveIn(RB, 'B'), energy('B', RB, 2, Energy).
home(burrow{rA: RA, rB: RB,       rC: RC, rD: RD, h1: H1, h2: H2, h3: H3, h4: [], h5: 'B', h6: H6, h7: H7},
     burrow{rA: RA, rB: ['B'|RB], rC: RC, rD: RD, h1: H1, h2: H2, h3: H3, h4: [], h5: [],  h6: H6, h7: H7}, Energy) :- canMoveIn(RB, 'B'), energy('B', RB, 4, Energy).
home(burrow{rA: RA, rB: RB,       rC: RC, rD: RD, h1: H1, h2: H2, h3: H3, h4: [], h5: [], h6: 'B', h7: H7},
     burrow{rA: RA, rB: ['B'|RB], rC: RC, rD: RD, h1: H1, h2: H2, h3: H3, h4: [], h5: [], h6: [],  h7: H7}, Energy) :- canMoveIn(RB, 'B'), energy('B', RB, 6, Energy).
home(burrow{rA: RA, rB: RB,       rC: RC, rD: RD, h1: H1, h2: H2, h3: H3, h4: [], h5: [], h6: [], h7: 'B'},
     burrow{rA: RA, rB: ['B'|RB], rC: RC, rD: RD, h1: H1, h2: H2, h3: H3, h4: [], h5: [], h6: [], h7: [] }, Energy) :- canMoveIn(RB, 'B'), energy('B', RB, 7, Energy).

home(burrow{rA: RA, rB: RB, rC: RC,       rD: RD, h1: 'C', h2: [], h3: [], h4: [], h5: H5, h6: H6, h7: H7},
     burrow{rA: RA, rB: RB, rC: ['C'|RC], rD: RD, h1: [],  h2: [], h3: [], h4: [], h5: H5, h6: H6, h7: H7}, Energy) :- canMoveIn(RC, 'C'), energy('C', RC, 7, Energy).
home(burrow{rA: RA, rB: RB, rC: RC,       rD: RD, h1: H1, h2: 'C', h3: [], h4: [], h5: H5, h6: H6, h7: H7},
     burrow{rA: RA, rB: RB, rC: ['C'|RC], rD: RD, h1: H1, h2: [],  h3: [], h4: [], h5: H5, h6: H6, h7: H7}, Energy) :- canMoveIn(RC, 'C'), energy('C', RC, 6, Energy).
home(burrow{rA: RA, rB: RB, rC: RC,       rD: RD, h1: H1, h2: H2, h3: 'C', h4: [], h5: H5, h6: H6, h7: H7},
     burrow{rA: RA, rB: RB, rC: ['C'|RC], rD: RD, h1: H1, h2: H2, h3: [],  h4: [], h5: H5, h6: H6, h7: H7}, Energy) :- canMoveIn(RC, 'C'), energy('C', RC, 4, Energy).
home(burrow{rA: RA, rB: RB, rC: RC,       rD: RD, h1: H1, h2: H2, h3: H3, h4: 'C', h5: H5, h6: H6, h7: H7},
     burrow{rA: RA, rB: RB, rC: ['C'|RC], rD: RD, h1: H1, h2: H2, h3: H3, h4: [],  h5: H5, h6: H6, h7: H7}, Energy) :- canMoveIn(RC, 'C'), energy('C', RC, 2, Energy).
home(burrow{rA: RA, rB: RB, rC: RC,       rD: RD, h1: H1, h2: H2, h3: H3, h4: H4, h5: 'C', h6: H6, h7: H7},
     burrow{rA: RA, rB: RB, rC: ['C'|RC], rD: RD, h1: H1, h2: H2, h3: H3, h4: H4, h5: [],  h6: H6, h7: H7}, Energy) :- canMoveIn(RC, 'C'), energy('C', RC, 2, Energy).
home(burrow{rA: RA, rB: RB, rC: RC,       rD: RD, h1: H1, h2: H2, h3: H3, h4: H4, h5: [], h6: 'C', h7: H7},
     burrow{rA: RA, rB: RB, rC: ['C'|RC], rD: RD, h1: H1, h2: H2, h3: H3, h4: H4, h5: [], h6: [],  h7: H7}, Energy) :- canMoveIn(RC, 'C'), energy('C', RC, 4, Energy).
home(burrow{rA: RA, rB: RB, rC: RC,       rD: RD, h1: H1, h2: H2, h3: H3, h4: H4, h5: [], h6: [], h7: 'C'},
     burrow{rA: RA, rB: RB, rC: ['C'|RC], rD: RD, h1: H1, h2: H2, h3: H3, h4: H4, h5: [], h6: [], h7: [] }, Energy) :- canMoveIn(RC, 'C'), energy('C', RC, 5, Energy).

home(burrow{rA: RA, rB: RB, rC: RC, rD: RD,       h1: 'D', h2: [], h3: [], h4: [], h5: [], h6: H6, h7: H7},
     burrow{rA: RA, rB: RB, rC: RC, rD: ['D'|RD], h1: [],  h2: [], h3: [], h4: [], h5: [], h6: H6, h7: H7}, Energy) :- canMoveIn(RD, 'D'), energy('D', RD, 9, Energy).
home(burrow{rA: RA, rB: RB, rC: RC, rD: RD,       h1: H1, h2: 'D', h3: [], h4: [], h5: [], h6: H6, h7: H7},
     burrow{rA: RA, rB: RB, rC: RC, rD: ['D'|RD], h1: H1, h2: [],  h3: [], h4: [], h5: [], h6: H6, h7: H7}, Energy) :- canMoveIn(RD, 'D'), energy('D', RD, 8, Energy).
home(burrow{rA: RA, rB: RB, rC: RC, rD: RD,       h1: H1, h2: H2, h3: 'D', h4: [], h5: [], h6: H6, h7: H7},
     burrow{rA: RA, rB: RB, rC: RC, rD: ['D'|RD], h1: H1, h2: H2, h3: [],  h4: [], h5: [], h6: H6, h7: H7}, Energy) :- canMoveIn(RD, 'D'), energy('D', RD, 6, Energy).
home(burrow{rA: RA, rB: RB, rC: RC, rD: RD,       h1: H1, h2: H2, h3: H3, h4: 'D', h5: [], h6: H6, h7: H7},
     burrow{rA: RA, rB: RB, rC: RC, rD: ['D'|RD], h1: H1, h2: H2, h3: H3, h4: [],  h5: [], h6: H6, h7: H7}, Energy) :- canMoveIn(RD, 'D'), energy('D', RD, 4, Energy).
home(burrow{rA: RA, rB: RB, rC: RC, rD: RD,       h1: H1, h2: H2, h3: H3, h4: H4, h5: 'D', h6: H6, h7: H7},
     burrow{rA: RA, rB: RB, rC: RC, rD: ['D'|RD], h1: H1, h2: H2, h3: H3, h4: H4, h5: [],  h6: H6, h7: H7}, Energy) :- canMoveIn(RD, 'D'), energy('D', RD, 2, Energy).
home(burrow{rA: RA, rB: RB, rC: RC, rD: RD,       h1: H1, h2: H2, h3: H3, h4: H4, h5: H5, h6: 'D', h7: H7},
     burrow{rA: RA, rB: RB, rC: RC, rD: ['D'|RD], h1: H1, h2: H2, h3: H3, h4: H4, h5: H5, h6: [],  h7: H7}, Energy) :- canMoveIn(RD, 'D'), energy('D', RD, 2, Energy).
home(burrow{rA: RA, rB: RB, rC: RC, rD: RD,       h1: H1, h2: H2, h3: H3, h4: H4, h5: H5, h6: [], h7: 'D'},
     burrow{rA: RA, rB: RB, rC: RC, rD: ['D'|RD], h1: H1, h2: H2, h3: H3, h4: H4, h5: H5, h6: [], h7: [] }, Energy) :- canMoveIn(RD, 'D'), energy('D', RD, 3, Energy).

move(burrow{rA: [Ah|At], rB: RB, rC: RC, rD: RD, h1: [], h2: [], h3: H3, h4: H4, h5: H5, h6: H6, h7: H7},
     burrow{rA: At,      rB: RB, rC: RC, rD: RD, h1: Ah, h2: [], h3: H3, h4: H4, h5: H5, h6: H6, h7: H7}, Energy) :- canMoveOut([Ah|At], 'A'), energy(Ah, At, 3, Energy).
move(burrow{rA: [Ah|At], rB: RB, rC: RC, rD: RD, h1: H1, h2: [], h3: H3, h4: H4, h5: H5, h6: H6, h7: H7},
     burrow{rA: At,      rB: RB, rC: RC, rD: RD, h1: H1, h2: Ah, h3: H3, h4: H4, h5: H5, h6: H6, h7: H7}, Energy) :- canMoveOut([Ah|At], 'A'), energy(Ah, At, 2, Energy).
move(burrow{rA: [Ah|At], rB: RB, rC: RC, rD: RD, h1: H1, h2: H2, h3: [], h4: H4, h5: H5, h6: H6, h7: H7},
     burrow{rA: At,      rB: RB, rC: RC, rD: RD, h1: H1, h2: H2, h3: Ah, h4: H4, h5: H5, h6: H6, h7: H7}, Energy) :- canMoveOut([Ah|At], 'A'), energy(Ah, At, 2, Energy).
move(burrow{rA: [Ah|At], rB: RB, rC: RC, rD: RD, h1: H1, h2: H2, h3: [], h4: [], h5: H5, h6: H6, h7: H7},
     burrow{rA: At,      rB: RB, rC: RC, rD: RD, h1: H1, h2: H2, h3: [], h4: Ah, h5: H5, h6: H6, h7: H7}, Energy) :- canMoveOut([Ah|At], 'A'), energy(Ah, At, 4, Energy).
move(burrow{rA: [Ah|At], rB: RB, rC: RC, rD: RD, h1: H1, h2: H2, h3: [], h4: [], h5: [], h6: H6, h7: H7},
     burrow{rA: At,      rB: RB, rC: RC, rD: RD, h1: H1, h2: H2, h3: [], h4: [], h5: Ah, h6: H6, h7: H7}, Energy) :- canMoveOut([Ah|At], 'A'), energy(Ah, At, 6, Energy).
move(burrow{rA: [Ah|At], rB: RB, rC: RC, rD: RD, h1: H1, h2: H2, h3: [], h4: [], h5: [], h6: [], h7: H7},
     burrow{rA: At,      rB: RB, rC: RC, rD: RD, h1: H1, h2: H2, h3: [], h4: [], h5: [], h6: Ah, h7: H7}, Energy) :- canMoveOut([Ah|At], 'A'), energy(Ah, At, 8, Energy).
move(burrow{rA: [Ah|At], rB: RB, rC: RC, rD: RD, h1: H1, h2: H2, h3: [], h4: [], h5: [], h6: [], h7: []},
     burrow{rA: At,      rB: RB, rC: RC, rD: RD, h1: H1, h2: H2, h3: [], h4: [], h5: [], h6: [], h7: Ah}, Energy) :- canMoveOut([Ah|At], 'A'), energy(Ah, At, 9, Energy).

move(burrow{rA: RA, rB: [Bh|Bt], rC: RC, rD: RD, h1: [], h2: [], h3: [], h4: H4, h5: H5, h6: H6, h7: H7},
     burrow{rA: RA, rB: Bt,      rC: RC, rD: RD, h1: Bh, h2: [], h3: [], h4: H4, h5: H5, h6: H6, h7: H7}, Energy) :- canMoveOut([Bh|Bt], 'B'), energy(Bh, Bt, 5, Energy).
move(burrow{rA: RA, rB: [Bh|Bt], rC: RC, rD: RD, h1: H1, h2: [], h3: [], h4: H4, h5: H5, h6: H6, h7: H7},
     burrow{rA: RA, rB: Bt,      rC: RC, rD: RD, h1: H1, h2: Bh, h3: [], h4: H4, h5: H5, h6: H6, h7: H7}, Energy) :- canMoveOut([Bh|Bt], 'B'), energy(Bh, Bt, 4, Energy).
move(burrow{rA: RA, rB: [Bh|Bt], rC: RC, rD: RD, h1: H1, h2: H2, h3: [], h4: H4, h5: H5, h6: H6, h7: H7},
     burrow{rA: RA, rB: Bt,      rC: RC, rD: RD, h1: H1, h2: H2, h3: Bh, h4: H4, h5: H5, h6: H6, h7: H7}, Energy) :- canMoveOut([Bh|Bt], 'B'), energy(Bh, Bt, 2, Energy).
move(burrow{rA: RA, rB: [Bh|Bt], rC: RC, rD: RD, h1: H1, h2: H2, h3: H3, h4: [], h5: H5, h6: H6, h7: H7},
     burrow{rA: RA, rB: Bt,      rC: RC, rD: RD, h1: H1, h2: H2, h3: H3, h4: Bh, h5: H5, h6: H6, h7: H7}, Energy) :- canMoveOut([Bh|Bt], 'B'), energy(Bh, Bt, 2, Energy).
move(burrow{rA: RA, rB: [Bh|Bt], rC: RC, rD: RD, h1: H1, h2: H2, h3: H3, h4: [], h5: [], h6: H6, h7: H7},
     burrow{rA: RA, rB: Bt,      rC: RC, rD: RD, h1: H1, h2: H2, h3: H3, h4: [], h5: Bh, h6: H6, h7: H7}, Energy) :- canMoveOut([Bh|Bt], 'B'), energy(Bh, Bt, 4, Energy).
move(burrow{rA: RA, rB: [Bh|Bt], rC: RC, rD: RD, h1: H1, h2: H2, h3: H3, h4: [], h5: [], h6: [], h7: H7},
     burrow{rA: RA, rB: Bt,      rC: RC, rD: RD, h1: H1, h2: H2, h3: H3, h4: [], h5: [], h6: Bh, h7: H7}, Energy) :- canMoveOut([Bh|Bt], 'B'), energy(Bh, Bt, 6, Energy).
move(burrow{rA: RA, rB: [Bh|Bt], rC: RC, rD: RD, h1: H1, h2: H2, h3: H3, h4: [], h5: [], h6: [], h7: []},
     burrow{rA: RA, rB: Bt,      rC: RC, rD: RD, h1: H1, h2: H2, h3: H3, h4: [], h5: [], h6: [], h7: Bh}, Energy) :- canMoveOut([Bh|Bt], 'B'), energy(Bh, Bt, 7, Energy).

move(burrow{rA: RA, rB: RB, rC: [Ch|Ct], rD: RD, h1: [], h2: [], h3: [], h4: [], h5: H5, h6: H6, h7: H7},
     burrow{rA: RA, rB: RB, rC: Ct,      rD: RD, h1: Ch, h2: [], h3: [], h4: [], h5: H5, h6: H6, h7: H7}, Energy) :- canMoveOut([Ch|Ct], 'C'), energy(Ch, Ct, 7, Energy).
move(burrow{rA: RA, rB: RB, rC: [Ch|Ct], rD: RD, h1: H1, h2: [], h3: [], h4: [], h5: H5, h6: H6, h7: H7},
     burrow{rA: RA, rB: RB, rC: Ct,      rD: RD, h1: H1, h2: Ch, h3: [], h4: [], h5: H5, h6: H6, h7: H7}, Energy) :- canMoveOut([Ch|Ct], 'C'), energy(Ch, Ct, 6, Energy).
move(burrow{rA: RA, rB: RB, rC: [Ch|Ct], rD: RD, h1: H1, h2: H2, h3: [], h4: [], h5: H5, h6: H6, h7: H7},
     burrow{rA: RA, rB: RB, rC: Ct,      rD: RD, h1: H1, h2: H2, h3: Ch, h4: [], h5: H5, h6: H6, h7: H7}, Energy) :- canMoveOut([Ch|Ct], 'C'), energy(Ch, Ct, 4, Energy).
move(burrow{rA: RA, rB: RB, rC: [Ch|Ct], rD: RD, h1: H1, h2: H2, h3: H3, h4: [], h5: H5, h6: H6, h7: H7},
     burrow{rA: RA, rB: RB, rC: Ct,      rD: RD, h1: H1, h2: H2, h3: H3, h4: Ch, h5: H5, h6: H6, h7: H7}, Energy) :- canMoveOut([Ch|Ct], 'C'), energy(Ch, Ct, 2, Energy).
move(burrow{rA: RA, rB: RB, rC: [Ch|Ct], rD: RD, h1: H1, h2: H2, h3: H3, h4: H4, h5: [], h6: H6, h7: H7},
     burrow{rA: RA, rB: RB, rC: Ct,      rD: RD, h1: H1, h2: H2, h3: H3, h4: H4, h5: Ch, h6: H6, h7: H7}, Energy) :- canMoveOut([Ch|Ct], 'C'), energy(Ch, Ct, 2, Energy).
move(burrow{rA: RA, rB: RB, rC: [Ch|Ct], rD: RD, h1: H1, h2: H2, h3: H3, h4: H4, h5: [], h6: [], h7: H7},
     burrow{rA: RA, rB: RB, rC: Ct,      rD: RD, h1: H1, h2: H2, h3: H3, h4: H4, h5: [], h6: Ch, h7: H7}, Energy) :- canMoveOut([Ch|Ct], 'C'), energy(Ch, Ct, 4, Energy).
move(burrow{rA: RA, rB: RB, rC: [Ch|Ct], rD: RD, h1: H1, h2: H2, h3: H3, h4: H4, h5: [], h6: [], h7: []},
     burrow{rA: RA, rB: RB, rC: Ct,      rD: RD, h1: H1, h2: H2, h3: H3, h4: H4, h5: [], h6: [], h7: Ch}, Energy) :- canMoveOut([Ch|Ct], 'C'), energy(Ch, Ct, 5, Energy).

move(burrow{rA: RA, rB: RB, rC: RC, rD: [Dh|Dt], h1: [], h2: [], h3: [], h4: [], h5: [], h6: H6, h7: H7},
     burrow{rA: RA, rB: RB, rC: RC, rD: Dt,      h1: Dh, h2: [], h3: [], h4: [], h5: [], h6: H6, h7: H7}, Energy) :- canMoveOut([Dh|Dt], 'D'), energy(Dh, Dt, 9, Energy).
move(burrow{rA: RA, rB: RB, rC: RC, rD: [Dh|Dt], h1: H1, h2: [], h3: [], h4: [], h5: [], h6: H6, h7: H7},
     burrow{rA: RA, rB: RB, rC: RC, rD: Dt,      h1: H1, h2: Dh, h3: [], h4: [], h5: [], h6: H6, h7: H7}, Energy) :- canMoveOut([Dh|Dt], 'D'), energy(Dh, Dt, 8, Energy).
move(burrow{rA: RA, rB: RB, rC: RC, rD: [Dh|Dt], h1: H1, h2: H2, h3: [], h4: [], h5: [], h6: H6, h7: H7},
     burrow{rA: RA, rB: RB, rC: RC, rD: Dt,      h1: H1, h2: H2, h3: Dh, h4: [], h5: [], h6: H6, h7: H7}, Energy) :- canMoveOut([Dh|Dt], 'D'), energy(Dh, Dt, 6, Energy).
move(burrow{rA: RA, rB: RB, rC: RC, rD: [Dh|Dt], h1: H1, h2: H2, h3: H3, h4: [], h5: [], h6: H6, h7: H7},
     burrow{rA: RA, rB: RB, rC: RC, rD: Dt,      h1: H1, h2: H2, h3: H3, h4: Dh, h5: [], h6: H6, h7: H7}, Energy) :- canMoveOut([Dh|Dt], 'D'), energy(Dh, Dt, 4, Energy).
move(burrow{rA: RA, rB: RB, rC: RC, rD: [Dh|Dt], h1: H1, h2: H2, h3: H3, h4: H4, h5: [], h6: H6, h7: H7},
     burrow{rA: RA, rB: RB, rC: RC, rD: Dt,      h1: H1, h2: H2, h3: H3, h4: H4, h5: Dh, h6: H6, h7: H7}, Energy) :- canMoveOut([Dh|Dt], 'D'), energy(Dh, Dt, 2, Energy).
move(burrow{rA: RA, rB: RB, rC: RC, rD: [Dh|Dt], h1: H1, h2: H2, h3: H3, h4: H4, h5: H5, h6: [], h7: H7},
     burrow{rA: RA, rB: RB, rC: RC, rD: Dt,      h1: H1, h2: H2, h3: H3, h4: H4, h5: H5, h6: Dh, h7: H7}, Energy) :- canMoveOut([Dh|Dt], 'D'), energy(Dh, Dt, 2, Energy).
move(burrow{rA: RA, rB: RB, rC: RC, rD: [Dh|Dt], h1: H1, h2: H2, h3: H3, h4: H4, h5: H5, h6: [], h7: []},
     burrow{rA: RA, rB: RB, rC: RC, rD: Dt,      h1: H1, h2: H2, h3: H3, h4: H4, h5: H5, h6: [], h7: Dh}, Energy) :- canMoveOut([Dh|Dt], 'D'), energy(Dh, Dt, 3, Energy).

canMoveOut(AmphipodsInRoom, Room) :- member(Amphipod, AmphipodsInRoom), Amphipod \= Room, !.
canMoveIn(AmphipodsInRoom, Room) :- forall(member(Amphipod, AmphipodsInRoom), Amphipod = Room).
     
energy('A', AlreadyInRoom, Steps, Energy) :- !, length(AlreadyInRoom, C), roomSize(Size), Energy is Steps + Size-1 - C.
energy('B', AlreadyInRoom, Steps, Energy) :- !, length(AlreadyInRoom, C), roomSize(Size), Energy is 10*(Steps + Size-1 - C).
energy('C', AlreadyInRoom, Steps, Energy) :- !, length(AlreadyInRoom, C), roomSize(Size), Energy is 100*(Steps + Size-1 - C).
energy('D', AlreadyInRoom, Steps, Energy) :- !, length(AlreadyInRoom, C), roomSize(Size), Energy is 1000*(Steps + Size-1 - C).

energy_out('A', OthersInRoom, Steps, Energy) :- !, length(OthersInRoom, C), roomSize(Size), Energy is Steps + Size-1 - C.
energy_out('B', OthersInRoom, Steps, Energy) :- !, length(OthersInRoom, C), roomSize(Size), Energy is 10*(Steps + Size-1 - C).
energy_out('C', OthersInRoom, Steps, Energy) :- !, length(OthersInRoom, C), roomSize(Size), Energy is 100*(Steps + Size-1 - C).
energy_out('D', OthersInRoom, Steps, Energy) :- !, length(OthersInRoom, C), roomSize(Size), Energy is 1000*(Steps + Size-1 - C).

/* required for loadData */
data_line(Amphipods, Line) :- string_chars(Line, Amphipods).
