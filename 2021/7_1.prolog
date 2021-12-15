day(7). testResult(37). solve :- ['lib/solve.prolog'], printResult.

result([Crabs], MinimumFuel) :- aggregate_all(min(FuelSum), totalRequiredFuel(Crabs, FuelSum), MinimumFuel).

requiredFuel(Crab, Target, Fuel) :- (Crab < Target -> Fuel is Target - Crab ; Fuel is Crab - Target).
totalRequiredFuel(Crabs, FuelSum) :-
  append(X, _, Crabs), length(X, Target),
  aggregate_all(sum(Fuel), (member(Crab, Crabs), requiredFuel(Crab, Target, Fuel)), FuelSum).

/* required for loadData */
data_line(Crabs, Line) :-  split_string(Line, ",", "", CrabsStr), maplist(number_string, Crabs, CrabsStr).
