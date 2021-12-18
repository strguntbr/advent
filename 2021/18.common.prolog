:- include('lib/solve.prolog'). day(18).

add([Number], [Reduced]) :- !, reduce(Number, Reduced).
add([H|[T|R]], Result) :- reduce([H,T], Reduced), add([Reduced|R], Result).

reduce(Number, Reduced) :- explode(Number, 4, _, _, Exploded), !, reduce(Exploded, Reduced).
reduce(Number, Reduced) :- split(Number, Split), !, reduce(Split, Reduced).
reduce(Number, Number).

/*explode(Pair, Level, Right, Left, Exploded).*/
explode([First,Second], Level, FirstLeft, Right, [ExplodedFirst,ExplodedSecond]) :-
  Level > 1, LevelN is Level - 1,
  explode(First, LevelN, FirstLeft, FirstRight, ExplodedFirst), !,
  (
    addToNextNumber(FirstRight, Second, ExplodedSecond) -> Right = 0
    ; Right = FirstRight
  ).
explode([First,Second], Level, Left, SecondRight, [ExplodedFirst,ExplodedSecond]) :-
  Level > 1, LevelN is Level - 1,
  explode(Second, LevelN, SecondLeft, SecondRight, ExplodedSecond), !,
  (
    addToPrevNumber(SecondLeft, First, ExplodedFirst) -> Left = 0
    ; Left = SecondLeft
  ).
explode([[F1,F2],Second], 1, Left, Right, [0,Exploded]) :-
  number(F1), number(F2), !, Left = F1,
  (
    addToNextNumber(F2, Second, Exploded) -> Right = 0
    ; Exploded = Second, Right = F2
  ).
explode([First,[S1,S2]], 1, Left, Right, [Exploded,0]) :-
  number(S1), number(S2), !, Right = S2,
  (
    addToPrevNumber(S1, First, Exploded) -> Left = 0
    ; Exploded = First, Left = S1
  ).

/*split(Number, Split)*/
split([First,Second], [FirstSplit,Second]) :- split(First, FirstSplit), !.
split([First,Second], [First,SecondSplit]) :- split(Second, SecondSplit), !.
split(Number, [First,Second]) :- number(Number), Number > 9, !, First is floor(Number / 2), Second is ceil(Number / 2).

/*addToNextNumber(Add, Number, Added).*/
addToNextNumber(0, Number, Number) :- !.
addToNextNumber(Add, [First,Second], [AddedFirst,Second]) :- addToNextNumber(Add, First, AddedFirst).
addToNextNumber(Add, Number, AddedNumber) :- number(Number), AddedNumber is Number + Add.

/*addToPrevNumber(Add, Number, Added).*/
addToPrevNumber(0, Number, Number).
addToPrevNumber(Add, [First,Second], [First,AddedSecond]) :- addToPrevNumber(Add, Second, AddedSecond).
addToPrevNumber(Add, Number, AddedNumber) :- number(Number), AddedNumber is Number + Add.

number_magnitude([First, Second], Magnitude) :- number_magnitude(First, FirstMagnitude), number_magnitude(Second, SecondMagnitude), Magnitude is 3 * FirstMagnitude + 2 * SecondMagnitude.
number_magnitude(RegularNumber, RegularNumber) :- number(RegularNumber).

/* required for loadData */
data_line(Number, Line) :- term_string(Number, Line).
