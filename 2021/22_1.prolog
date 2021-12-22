:- include('22.common.prolog'). testResult('test1', 39). testResult('test2', 590784).

result(Instructions, ActiveCubes) :- 
  initInstructions(Instructions, InitInstructions),
  init(InitInstructions),
  aggregate_all(count, on(_,_,_), ActiveCubes).

init([]).
init([FirstInstruction|OtherInstructions]) :- execute(FirstInstruction), init(OtherInstructions).

execute(op{o: Op, c:[[X1,X2], [Y1,Y2], [Z1,Z2]]}) :- foreach((between(X1,X2,Xc), between(Y1,Y2,Yc), between(Z1,Z2,Zc)), turn(Op, Xc,Yc,Zc)).

turn('on', X, Y, Z) :- isOn(X, Y, Z) ; assert(on(X,Y,Z)).
turn('off', X, Y, Z) :- retractall(on(X,Y,Z)).
isOn(X, Y, Z) :- current_predicate(on/3) -> on(X,Y,Z).

initInstructions(Instructions, InitInstruction) :- maplist(limitInstruction, Instructions, InitInstruction).
limitInstruction(op{o: Op, c: Cuboid}, op{o: Op, c: LimitedCuboid}) :- limitCuboid(Cuboid, LimitedCuboid).
limitCuboid(Cuboid, LimitedCuboid) :- maplist(limitDimension, Cuboid, LimitedCuboid).
limitDimension([From, To], [LimitedFrom, LimitedTo]) :- LimitedFrom is max(From, -50), LimitedTo is min(To, 50).
