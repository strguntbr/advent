setMemory(OLD_MEMORY, mem{addr: ADDR, val: VAL}, MASK, NEW_MEMORY) :-
  calcAddresses(ADDR, MASK, ADDRESSES),
  removeAll(OLD_MEMORY, ADDRESSES, I_MEMORY),
  addAll(I_MEMORY, ADDRESSES, VAL, NEW_MEMORY).
remove([], mem{addr: _, val: 0}, []).
remove([H|T], H, T) :- !.
remove([H|T], E, [H|Tr]) :- remove(T, E, Tr).
removeAll(L, [], L).
removeAll(L, [H|T], R) :- remove(L, mem{addr: H, val: _}, I), removeAll(I, T, R).
addAll(MEMORY, [], _, MEMORY).
addAll(OLD_MEMORY, [H|T], VAL, [mem{addr: H, val: VAL}|Tr]) :- addAll(OLD_MEMORY, T, VAL, Tr).

addToAll([], _, []) :- !.
addToAll([H|T], V, [[V|H]|To]) :- addToAll(T, V, To).
calcBitAddresses([], _, [[]]).
calcBitAddresses([Ha|Ta], [], Tn) :- !, calcBitAddresses(Ta, [], Ti), addToAll(Ti, Ha, Tn).
calcBitAddresses([Ha|Ta], [0|Tm], Tn) :- !, calcBitAddresses(Ta, Tm, Ti), addToAll(Ti, Ha, Tn).
calcBitAddresses([_|Ta], [1|Tm], Tn) :- !, calcBitAddresses(Ta, Tm, Ti), addToAll(Ti, 1, Tn).
calcBitAddresses([_|Ta], ['X'|Tm], Tn) :- !, calcBitAddresses(Ta, Tm, Ti), addToAll(Ti, 0, Ti0), addToAll(Ti, 1, Ti1), append(Ti0, Ti1, Tn).
calcAddresses(ADDR, MASK, ADDRESSES) :-
  number_binary(ADDR, 36, ADDR_BITS),
  calcBitAddresses(ADDR_BITS, MASK, ADDRESSES_BITS),
  binaries_numbers(ADDRESSES_BITS, ADDRESSES).

number_binary(0, 1, [0]). number_binary(1, 0, [1]).
number_binary(NUMBER, C, [B|T]) :-
  C > 1, plus(Ct, 1, C),
  B is NUMBER mod 2,
  NUMBERt is NUMBER div 2,
  number_binary(NUMBERt, Ct, T).
binary_number([], 0).
binary_number([0|T], VAL) :- binary_number(T, VALt), VAL is VALt*2.
binary_number([1|T], VAL) :- binary_number(T, VALt), VAL is VALt*2+1.
binaries_numbers([], []).
binaries_numbers([H|T], [Hr|Tr]) :- binary_number(H, Hr), binaries_numbers(T, Tr).

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
