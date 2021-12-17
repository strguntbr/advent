:- include('lib/solve.prolog'). day(15). testResult(40).

result(RiskMap, Risk) :-
  initFacts(RiskMap), assert(pathTo([0, 0], 0)),
  mapSize(RiskMap, SX, SY), X is SX - 1, Y is SY - 1,
  calculatePaths([X, Y], Risk).

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

initFacts(RiskMap) :-
  retractall(node(_, _)),    /* node([X,Y], Risk)             */
  retractall(pathTo(_, _)),  /* pathTo([X,Y], Risk)           */
  retractall(edge(_, _, _)), /* edge([X1,Y1], [X2,Y2], Risk2) */
  retractall(done(_)),       /* done([X,Y])                   */
  initRisks(RiskMap, 0), initEdges.

initRisks([], _).
initRisks([Line1|OtherLines], X) :- initRisks(Line1, X, 0), XN is X + 1, initRisks(OtherLines, XN).
initRisks([], _, _).
initRisks([Risk1|OtherRisks], X, Y) :- assert(node([X, Y], Risk1)), YN is Y + 1, initRisks(OtherRisks, X, YN).

initEdges :- forall(adjacentRiskPair(P1, P2, Risk2), initEdge(P1, P2, Risk2)).
initEdge(P1, P2, Risk) :- assert(edge(P1, P2, Risk)).
adjacentRiskPair([X1, Y1], [X2, Y2], Risk2) :- node([X1, Y1], _), adjacent([X1, Y1], [X2, Y2]), node([X2, Y2], Risk2).
adjacent([X, Y1], [X, Y2]) :- Y2 is Y1 - 1 ; Y2 is Y1 + 1.
adjacent([X1, Y], [X2, Y]) :- X2 is X1 - 1 ; X2 is X1 + 1.

/* required for loadData */
data_line(Risks, Line) :- string_chars(Line, RiskChars), maplist(atom_number, RiskChars, Risks).
