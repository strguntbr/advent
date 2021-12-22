:- include('22.common.prolog'). testResult('test3', 2758514936282235).

result(Instructions, ActiveCubes) :- 
  reboot(Instructions, [], ResultingCuboids),
  aggregate_all(
    sum(Cubes),
    (
      member(Cuboid, ResultingCuboids),
      Cuboid=[[Xs,Xe],[Ys,Ye],[Zs,Ze]],
      Cubes is (Xe-Xs+1) * (Ye-Ys+1) * (Ze-Zs+1)
    ),
    ActiveCubes
  ).

reboot([], Cuboids, Cuboids).
reboot([FirstInstruction|OtherInstructions], Cuboids, Result) :- execute(FirstInstruction, Cuboids, NextCuboids), reboot(OtherInstructions, NextCuboids, Result).

execute(op{o: 'on', c: Cuboid}, ActiveCuboids, [Cuboid|NextActiveCuboids]) :- subtractFromAll(ActiveCuboids, Cuboid, NextActiveCuboids).
execute(op{o: 'off', c: Cuboid}, ActiveCuboids, NextActiveCuboids) :- subtractFromAll(ActiveCuboids, Cuboid, NextActiveCuboids).

subtractFromAll(Cuboids, SubtractCuboids, Difference) :-
  maplist([A,B]>>subtract(A, SubtractCuboids, B), Cuboids, ListOfCuboids),
  append(ListOfCuboids, Difference).

subtract(Cuboid, SubtractCuboid, Difference) :-
  overlap(Cuboid, SubtractCuboid) -> (
    s_front(Cuboid, SubtractCuboid, DF),
    s_middle(Cuboid, SubtractCuboid, DM),
    s_back(Cuboid, SubtractCuboid, DB),
    append([DF,DM,DB], Difference)
  )
  ; Difference = [Cuboid].

s_front(Cube1, Cube2, R) :-
  Cube1=[[X1s,X1e],Y1,Z1],
  Cube2=[[X2s,_],_,_],
  (
    X1s < X2s -> X1en is min(X1e,X2s-1), CubeR=[[X1s,X1en],Y1,Z1], R=[CubeR]
    ; R = []
  ).

s_middle(Cube1, Cube2, R) :-
  Cube1=[[X1s,X1e],Y1,Z1],
  Cube2=[[X2s,X2e],Y2,Z2],
  XMs is max(X1s, X2s),
  XMe is min(X1e, X2e),
  (
    XMs =< XMe ->
      CM1=[[XMs,XMe],Y1,Z1],
      CM2=[[XMs,XMe],Y2,Z2],
      s_middle_top(CM1, CM2, MT),
      s_middle_middle(CM1, CM2, MM),
      s_middle_bottom(CM1, CM2, MB),
      append([MT, MM, MB], R)
    ; R = []
  ). 

s_back(Cube1, Cube2, R) :-
  Cube1=[[X1s,X1e],Y1,Z1],
  Cube2=[[_,X2e],_,_],
  (
    X1e > X2e -> X1sn is max(X1s,X2e+1), CubeR=[[X1sn,X1e],Y1,Z1], R=[CubeR]
    ; R = []
  ).

s_middle_top(Cube1, Cube2, R) :-
  Cube1=[X,[Y1s,Y1e],Z1],
  Cube2=[X,[Y2s,_],_],
  (
    Y1s < Y2s -> Y1en is min(Y1e,Y2s-1), CubeR=[X, [Y1s, Y1en], Z1], R=[CubeR]
    ; R = []
  ).

s_middle_middle(Cube1, Cube2, R) :-
  Cube1=[X,[Y1s,Y1e],Z1],
  Cube2=[X,[Y2s,Y2e],Z2],
  YMs is max(Y1s, Y2s),
  YMe is min(Y1e, Y2e),
  (
    YMs =< YMe ->
      CM1=[X,[YMs,YMe],Z1],
      CM2=[X,[YMs,YMe],Z2],
      s_middle_middle_left(CM1, CM2, ML),
      s_middle_middle_right(CM1, CM2, MR),
      append([ML, MR], R)
    ; R = []
  ).

s_middle_bottom(Cube1, Cube2, R) :-
  Cube1=[X,[Y1s,Y1e],Z1],
  Cube2=[X,[_,Y2e],_],
  (
    Y1e > Y2e -> Y1sn is max(Y1s,Y2e+1), CubeR=[X, [Y1sn, Y1e], Z1], R=[CubeR]
    ; R = []
  ).

s_middle_middle_left(Cube1, Cube2, R) :-
  Cube1=[X,Y,[Z1s,Z1e]],
  Cube2=[X,Y,[Z2s,_]],
  (
    Z1s < Z2s -> Z1en is min(Z1e,Z2s-1), CubeR=[X,Y,[Z1s,Z1en]], R=[CubeR]
    ; R = []
  ).

s_middle_middle_right(Cube1, Cube2, R) :-
  Cube1=[X,Y,[Z1s,Z1e]],
  Cube2=[X,Y,[_,Z2e]],
  (
    Z1e > Z2e -> Z1sn is max(Z1s,Z2e+1), CubeR=[X,Y,[Z1sn,Z1e]], R=[CubeR]
    ; R = []
  ).

overlap([X1,Y1,Z1], [X2,Y2,Z2]) :- dimensionOverlaps(X1, X2), dimensionOverlaps(Y1, Y2), dimensionOverlaps(Z1, Z2).
dimensionOverlaps([S1,E1], [S2,E2]) :-  S2 =< E1, E2 >= S1.
