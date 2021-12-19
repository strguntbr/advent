:- include('lib/solve.prolog'). day(19). groupData.

alignAllScans(Input, AlignedScans) :-
  retractall(id(_)), assert(id(1)),
  maplist(add_meta_info, Input, Scans),
  findall([Scan1, Scan2],
    ( 
      select2(Scan1, Scan2, Scans), Scan1.id < Scan2.id,
      possibleNeighbors(Scan1, Scan2)
    ),
    PossibleNeighborPairs
  ),
  [FirstScan|_] = Scans, alignAll([FirstScan], PossibleNeighborPairs, AlignedScans).


add_meta_info([Scanner|Beacons], scan{id: Id, s: Scanner, b: Beacons, d: Distances}) :- nextId(Id), beacon_distances(Beacons, Distances).
beacon_distances(Beacons, Distances) :-
  findall(dist{x:X, y:Y, z:Z, v:D},
    (
      select2([X1,Y1,Z1], [X2,Y2,Z2], Beacons),
      X is X1-X2, Y is Y1-Y2, Z is Z1-Z2,
      D is sqrt(X^2 + Y^2 + Z^2)
    ),
    Distances
  ).

possibleNeighbors(Scan1, Scan2) :-
  Scan1 \= Scan2,
  maplist(distance_value, Scan1.d, D1),
  maplist(distance_value, Scan2.d, D2),  
  intersection(D1, D2, SameDistances), length(SameDistances, L), L >= 12*11.

distance_value(D, D.v).

alignAll(AlreadyAligned, Neighbors, AlignedScans) :-
  alignOne(AlreadyAligned, Neighbors, RemainingNeighbors, NewAligned), !,
  alignAll(NewAligned, RemainingNeighbors, AlignedScans).
alignAll(AlreadyAligned, [], AlreadyAligned).

alignOne(AlreadyAligned, Neighbors, RemainingNeighbors, [Aligned|AlreadyAligned]) :-
  member(Master, AlreadyAligned),
  select([Scan1, Scan2], Neighbors, RemainingNeighbors),
  (
    Master.id=Scan1.id -> align(Master, Scan2, Aligned)
    ; Master.id=Scan2.id -> align(Master, Scan1, Aligned)
  ).

align(Master, Scan, AlignedScan) :- find_rotation(Master, Scan, RotatedScan), find_shift(Master, RotatedScan, AlignedScan).

find_rotation(Master, Scan, scan{id: Id, s: Scanner, b: RotatedBeacons, d: RotatedDistances}) :-
  possibleRotation(R),
  maplist([D,DR]>>rotate_distance(D,R,DR), Scan.d, RotatedDistances),
  intersection(Master.d, RotatedDistances, SameDistances), length(SameDistances, L), L >= 12*11,
  maplist([B,BR]>>rotate_pos(B,R,BR), Scan.b, RotatedBeacons),
  rotate_pos(Scan.s, R, Scanner),
  Id=Scan.id.

rotate_distance(dist{x: X, y:Y, z:Z, v:D}, R, dist{x: RX, y:RY, z:RZ, v:D}) :- rotate_pos([X,Y,Z], R, [RX,RY,RZ]).

rotate_pos([X,Y,Z], [XVal, YVal, ZVal], [RX,RY,RZ]) :- pick_value([X,Y,Z], XVal, RX), pick_value([X,Y,Z], YVal, RY), pick_value([X,Y,Z], ZVal, RZ).

find_shift(Master, Scan, scan{id: Id, s: Scanner, b: ShiftedBeacons, d: Distances}) :-
  intersection(Master.d, Scan.d, SameDistances),
  find_matching_points(Master, Scan, SameDistances, [X1, Y1, Z1], [X2, Y2, Z2]),
  XD is X1-X2, YD is Y1-Y2, ZD is Z1-Z2,
  maplist([B,BS]>>shift_pos(B,[XD,YD,ZD],BS), Scan.b, ShiftedBeacons),
  shift_pos(Scan.s, [XD,YD,ZD], Scanner),
  Id=Scan.id, Distances=Scan.d.

shift_pos([X,Y,Z], [DX,DY,DZ], [SX,SY,SZ]) :- SX is X+DX, SY is Y+DY, SZ is Z+DZ.

find_matching_points(ScanA, ScanB, SameDistances, PointA, PointB) :-
  member(D, SameDistances),
  findall(PA, selectWithDistance(ScanA.b, D, PA), [A1, A2]),
  findall(PB, selectWithDistance(ScanB.b, D, PB), [B1, B2]),
  A1=[A1X,A1Y,A1Z], A2=[A2X,A2Y,A2Z], B1=[B1X,B1Y,B1Z], B2=[B2X,B2Y,B2Z],
  AXD is A1X-A2X, AYD is A1Y-A2Y, AZD is A1Z-A2Z,
  BXD is B1X-B2X, BYD is B1Y-B2Y, BZD is B1Z-B2Z,
  (
    AXD=BXD, AYD=BYD, AZD=BZD -> PointA = A1, PointB = B1
    ; AXD is -BXD, AYD is -BYD, AZD is -BZD -> PointA = A1, PointB = B2
  ).
  
selectWithDistance(Beacons, Distance, [X,Y,Z]) :-
  member([X,Y,Z], Beacons),
  member([X2,Y2,Z2], Beacons),
  Distance.v is sqrt((X-X2)^2 + (Y-Y2)^2 + (Z-Z2)^2).
  
pick_value([X,_,_], 'x', X).
pick_value([X,_,_], 'xn', XN) :- XN is -X.
pick_value([_,Y,_], 'y', Y).
pick_value([_,Y,_], 'yn', YN) :- YN is -Y.
pick_value([_,_,Z], 'z', Z).
pick_value([_,_,Z], 'zn', ZN) :- ZN is -Z.
  
possibleRotation(Rotation) :- member(Rotation, 
  [
    ['x','y','z'], ['x','zn','y'], ['x','yn','zn'], ['x','z','yn'],
    ['y','xn','z'], ['y','z','x'], ['y','x','zn'], ['y','zn','xn'],
    ['z','y','xn'], ['z','x','y'], ['z','yn','x'], ['z','xn','yn'],

    ['xn','yn','z'], ['xn','z','y'], ['xn','y','zn'], ['xn','zn','yn'],
    ['yn','x','z'], ['yn','zn','x'], ['yn','xn','zn'], ['yn','z','xn'],
    ['zn','yn','xn'], ['zn','xn','y'], ['zn','y','x'], ['zn','x','yn']
  ]).

select2(Elem1, Elem2, List) :- member(Elem1, List), member(Elem2, List), Elem1 \= Elem2.

nextId(ID) :- id(ID), retractall(id(_)), NextID is ID+1, assert(id(NextID)).

/* required for loadData */
data_line(Pos, Line) :- split_string(Line, ',', '', PosStr), maplist(number_string, Pos, PosStr), !.
data_line([0,0,0], _). /* header line, add 0,0,0 as position of the scanner itself */
