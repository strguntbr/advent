:- include('18.common.prolog').
initDynamicTests :-
  number_magnitude([[[[0,9],2],3],4], A), assert(dynTestResult('testa', A)),
  number_magnitude([7,[6,[5,[7,0]]]], B), assert(dynTestResult('testb', B)),
  number_magnitude([[6,[5,[7,0]]],3], C), assert(dynTestResult('testc', C)),
  number_magnitude([[3,[2,[8,0]]],[9,[5,[7,0]]]], D), assert(dynTestResult('testd', D)),
  number_magnitude([[3,[2,[8,0]]],[9,[5,[7,0]]]], E), assert(dynTestResult('teste', E)),
  number_magnitude([[[[0,7],4],[[7,8],[6,0]]],[8,1]], F), assert(dynTestResult('testf', F)),
  number_magnitude([[[[1,1],[2,2]],[3,3]],[4,4]], G), assert(dynTestResult('test1', G)),
  number_magnitude([[[[3,0],[5,3]],[4,4]],[5,5]], H), assert(dynTestResult('test2', H)),
  number_magnitude([[[[5,0],[7,4]],[5,5]],[6,6]], I), assert(dynTestResult('test3', I)).
testResult(Test, Result) :- dynTestResult(Test, Result).
testResult('test', 4140).

result(Numbers, Magnitude) :- add(Numbers, [Result]), number_magnitude(Result, Magnitude).
