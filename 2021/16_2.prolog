:- include('16.common.prolog').

testResult('2.test1', 3). testResult('2.test2', 54). testResult('2.test3', 7). testResult('2.test4', 9).
testResult('2.test5', 1). testResult('2.test6', 0). testResult('2.test7', 0). testResult('2.test8', 1).

eval(_, 0, [], 0).
eval(_, 0, [FirstVal|OtherVals], Sum)     :- eval(_, 0, OtherVals, OtherSum), Sum is FirstVal + OtherSum.
eval(_, 1, [], 1).
eval(_, 1, [FirstVal|OtherVals], Product) :- eval(_, 1, OtherVals, OtherProduct), Product is FirstVal * OtherProduct.
eval(_, 2, Vals, Min)                     :- min_list(Vals, Min).
eval(_, 3, Vals, Max)                     :- max_list(Vals, Max).
eval(_, 4, Literal, Literal).
eval(_, 5, [Val1, Val2], Greater)         :- (Val1 > Val2 -> Greater = 1 ; Greater = 0).
eval(_, 6, [Val1, Val2], Less)            :- (Val1 < Val2 -> Less = 1 ; Less = 0).
eval(_, 7, [Val1, Val2], Equal)           :- (Val1 = Val2 -> Equal = 1 ; Equal = 0).
