:- include('lib/solve.prolog'). day(15). testResult(315).

result(RiskMap, Risk) :-
  mapSize(RiskMap, SX, SY), initFacts(RiskMap, SX, SY),
  assert(pathTo([0, 0], 0)),
  X is SX * 5 - 1, Y is SY * 5 - 1, calculatePaths([X, Y], Risk).

mapSize([Line1|OtherLines], X, Y) :- length(Line1, X), length([Line1|OtherLines], Y).

calculatePaths(To, Risk) :- findCheapestUnfinished(NextNode, NextRisk), (
  NextNode = To -> Risk = NextRisk
  ; calculateNextPaths(NextNode, NextRisk) -> calculatePaths(To, Risk)
).

findCheapestUnfinished(CheapestNode, CheapestNodeRisk) :-
  aggregate_all(min(Risk, Node), pathTo(Node, Risk), min(CheapestNodeRisk, CheapestNode)),
  retractall(pathTo(CheapestNode, CheapestNodeRisk)).

calculateNextPaths(ViaNode, ViaRisk) :-
  assert(done(ViaNode)),
  forall(findEdgeToUnfinished(ViaNode, To, ToRisk), assertPathTo(To, ViaRisk + ToRisk)).
assertPathTo(To, RiskFormula) :- 
  Risk is RiskFormula, (
    (pathTo(To, ExistingPathRisk), Risk >= ExistingPathRisk) -> true ;
    retractall(pathTo(To, _)), assert(pathTo(To, Risk))
  ).

findEdgeToUnfinished(From, To, Risk) :- edge(From, To, Risk), not(done(To)).

initFacts(RiskMap, SX, SY) :-
  retractall(node(_, _)),    /* node([X,Y], Risk)             */
  retractall(pathTo(_, _)),  /* pathTo([X,Y], Risk)           */
  retractall(edge(_, _, _)), /* edge([X1,Y1], [X2,Y2], Risk2) */
  retractall(done(_)),       /* done([X,Y])                   */
  initRisks(RiskMap, 0, SX, SY), initEdges.

initRisks([], _, _, _).
initRisks([Line1|OtherLines], X, SX, SY) :- initRisks(Line1, X, 0, SX, SY), XN is X + 1, initRisks(OtherLines, XN, SX, SY).
initRisks([], _, _, _, _).
initRisks([Risk1|OtherRisks], X, Y, SX, SY) :- assertNodes(X, Y, Risk1, SX, SY, 5, 5), YN is Y + 1, initRisks(OtherRisks, X, YN, SX, SY).
assertNodes(_, _, _,  _,  _,  0, _ ) :- !.
assertNodes(X, Y, R, SX, SY, CX, CY) :-
  assertNodesLine(X, Y, R, SX, SY, CY),
  XN is X + SX, CXN is CX - 1, nextRisk(R, RN),
  assertNodes(XN, Y, RN, SX, SY, CXN, CY).
assertNodesLine(_, _, _, _, _, 0) :- !.
assertNodesLine(X, Y, R, SX, SY, CY) :-
  assert(node([X, Y], R)),
  YN is Y + SY, CYN is CY - 1, nextRisk(R, RN),
  assertNodesLine(X, YN, RN, SX, SY, CYN).

nextRisk(9, 1) :- !.
nextRisk(R, RN) :- RN is R + 1.

initEdges :- forall(adjacentRiskPair(P1, P2, Risk2), initEdge(P1, P2, Risk2)).
initEdge(P1, P2, Risk) :- assert(edge(P1, P2, Risk)).
adjacentRiskPair([X1, Y1], [X2, Y2], Risk2) :- node([X1, Y1], _), adjacent([X1, Y1], [X2, Y2]), node([X2, Y2], Risk2).
adjacent([X, Y1], [X, Y2]) :- Y2 is Y1 - 1 ; Y2 is Y1 + 1.
adjacent([X1, Y], [X2, Y]) :- X2 is X1 - 1 ; X2 is X1 + 1.

/* required for loadData */
data_line(Risks, Line) :- string_chars(Line, RiskChars), maplist(atom_number, RiskChars, Risks).
