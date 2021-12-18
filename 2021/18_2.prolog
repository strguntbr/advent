:- include('18.common.prolog'). testResult('test', 3993).

result(Numbers, LargestMagnitude) :-
  aggregate_all(max(Magnitude), magnitude(Numbers, Magnitude), LargestMagnitude),
  true.

magnitude(Numbers, Magnitude) :-
  select(First, Numbers, T), member(Second, T),
  add([First,Second], [Reduced]),
  number_magnitude(Reduced, Magnitude).
