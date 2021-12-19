:- include('19.common.prolog'). testResult(79).

result(Input, Result) :-
  alignAllScans(Input, AlignedScans),
  setof(Beacon, beaconMember(Beacon, AlignedScans), UniqueBeacons),
  length(UniqueBeacons, Result).

beaconMember(Beacon, Scans) :- member(Scan, Scans), member(Beacon, Scan.b).