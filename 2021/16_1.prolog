:- include('16.common.prolog').

testResult('1.test1', 16). testResult('1.test2', 12). testResult('1.test3', 23). testResult('1.test4', 31).

eval(Version, 4, _, Version).
eval(Version, _, List, Result) :- sum_list([Version|List], Result).
