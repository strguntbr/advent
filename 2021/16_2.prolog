:- include('16.common.prolog').

testResult('2.test1', 3). testResult('2.test2', 54). testResult('2.test3', 7). testResult('2.test4', 9).
testResult('2.test5', 1). testResult('2.test6', 0). testResult('2.test7', 0). testResult('2.test8', 1).

eval(_, 0, Vals, Sum)             :- sum_list(Vals, Sum),                        print('+-- (~w) Operation: Sum~n', [Sum]).
eval(_, 1, Vals, Product)         :- prod_list(Vals, Product),                   print('+-- (~w) Operation: Product~n', [Product]).
eval(_, 2, Vals, Min)             :- min_list(Vals, Min),                        print('+-- (~w) Operation: Min~n', [Min]).
eval(_, 3, Vals, Max)             :- max_list(Vals, Max),                        print('+-- (~w) Operation: Max~n', [Max]).
eval(_, 4, Literal, Literal)      :-                                             print('+--: ~w~n', [Literal]).
eval(_, 5, [Val1, Val2], Greater) :- (Val1 > Val2 -> Greater = 1 ; Greater = 0), print('+-- (~w) Operation: GreaterThan~n', [Greater]).
eval(_, 6, [Val1, Val2], Less)    :- (Val1 < Val2 -> Less = 1 ; Less = 0),       print('+-- (~w) Operation: LessThan~n', [Less]).
eval(_, 7, [Val1, Val2], Equal)   :- (Val1 = Val2 -> Equal = 1 ; Equal = 0),     print('+-- (~w) Operation: EqualTo~n', [Equal]).

prod_list(List, Product) :- ( List = [H|T] -> prod_list(T, PN), Product is H*PN ; Product is 1).

print(Format, Values) :- (current_predicate(logEnabled/0), logEnabled) -> printIndent, format(Format, Values) ; true.
printIndent :- (current_predicate(indentation/1), indentation(I)) -> printIndent(I) ; true.
printIndent(I) :- I > 0 -> write("  "), IN is I - 1, printIndent(IN) ; true.
log :- assert(logEnabled).