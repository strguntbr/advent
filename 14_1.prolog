setMemory(OLD_MEMORY, mem{addr: ADDR, val: VAL}, MASK, [mem{addr: ADDR, val: NEW_VAL}|NEW_MEMORY]) :-
  remove(OLD_MEMORY, mem{addr: ADDR, val: _}, NEW_MEMORY),
  calcVal(VAL, MASK, NEW_VAL).
remove([], mem{addr: _, val: 0}, []).
remove([H|T], H, T) :- !.
remove([H|T], E, [H|Tr]) :- remove(T, E, Tr).
calcBitVal([], _, []) :- !.
calcBitVal([Hv|Tv], [], [Hv|Tn]) :- !, calcBitVal(Tv, [], Tn).
calcBitVal([Hv|Tv], ['X'|Tm], [Hv|Tn]) :- !, calcBitVal(Tv, Tm, Tn).
calcBitVal([_|Tv], [Hm|Tm], [Hm|Tn]) :- calcBitVal(Tv, Tm, Tn).
calcVal(VAL, MASK, NEW_VAL) :-
  number_binary(VAL, 36, VALb),
  calcBitVal(VALb, MASK, NEW_VALb),
  binary_number(NEW_VALb, NEW_VAL).

number_binary(0, 1, [0]). number_binary(1, 0, [1]).
number_binary(NUMBER, C, [B|T]) :-
  C > 1, plus(Ct, 1, C),
  B is NUMBER mod 2,
  NUMBERt is NUMBER div 2,
  number_binary(NUMBERt, Ct, T).
binary_number([], 0).
binary_number([0|T], VAL) :- binary_number(T, VALt), VAL is VALt*2.
binary_number([1|T], VAL) :- binary_number(T, VALt), VAL is VALt*2+1.

execute([], MEMORY, _, MEMORY).
execute([mem{addr: ADDR, val: VAL}|PROGRAM], OLD_MEMORY, MASK, NEW_MEMORY) :-
  setMemory(OLD_MEMORY, mem{addr: ADDR, val: VAL}, MASK, NEXT_MEMORY),
  execute(PROGRAM, NEXT_MEMORY, MASK, NEW_MEMORY).
execute([mask{bits: MASK}|PROGRAM], OLD_MEMORY, _, NEW_MEMORY) :-
  execute(PROGRAM, OLD_MEMORY, MASK, NEW_MEMORY).

defaultMask([]).

sumMemoryVals([], 0).
sumMemoryVals([mem{addr: _, val: VAL}|MEMORY], SUM) :- sumMemoryVals(MEMORY, SUMo), plus(SUMo, VAL, SUM).

solve(FILE) :-
  ['lib/loadData.prolog'], 
  loadData(PROGRAM, FILE),
  defaultMask(MASK),
  execute(PROGRAM, [], MASK, MEMORY),
  sumMemoryVals(MEMORY, SUM),
  write(SUM).
solve :- solve('input/14.data').

/* required for loadData */
data_line(OP, LINE) :- split_string(LINE, "=", " ", [CMD, ARG]), createOp(CMD, ARG, OP).
createOp("mask", BITMASK, mask{bits: BITS}) :- string_chars(BITMASK, BITCHARS), bitmask(BITCHARS, 36, BITSr), reverse(BITSr, BITS).
createOp(CMD, VALStr, mem{addr: ADDR, val: VAL}) :- split_string(CMD, "[", "]", ["mem", ADDRstr]), number_string(VAL, VALStr), number_string(ADDR, ADDRstr).
bitmask([], 0, []).
bitmask([H|T], C, [Hm|Tm]) :- maskchar(H, Hm), plus(C, -1, Cn), bitmask(T, Cn, Tm).
maskchar('1', 1). maskchar('0', 0). maskchar('X', 'X').
