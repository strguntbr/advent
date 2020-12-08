validIndex(PROGRAM, INDEX) :- length(PROGRAM, L), between(0, L, INDEX).

instrAtIndex([INSTR1|_], 0, INSTR1) :- !.
instrAtIndex([_|REST_OF_PROGRAM], INDEX, INSTR) :- INDEX2 is INDEX - 1, instrAtIndex(REST_OF_PROGRAM, INDEX2, INSTR).

evalInstr(PROGRAM, instr{op : "nop", arg: _}, INDEX, ACC, FIXED, NEXT_INDEX, ACC, FIXED) :- validIndex(PROGRAM, INDEX), NEXT_INDEX is INDEX + 1.
evalInstr(PROGRAM, instr{op : "acc", arg: ARG}, INDEX, ACC, FIXED, NEXT_INDEX, NEXT_ACC, FIXED) :- validIndex(PROGRAM, INDEX), NEXT_INDEX is INDEX + 1, NEXT_ACC is ACC + ARG.
evalInstr(PROGRAM, instr{op : "jmp", arg: ARG}, INDEX, ACC, FIXED, NEXT_INDEX, ACC, FIXED) :- validIndex(PROGRAM, INDEX), NEXT_INDEX is INDEX + ARG.
evalInstr(PROGRAM, instr{op : "nop", arg: ARG}, INDEX, ACC, FIXED, NEXT_INDEX, ACC, NEXT_FIXED) :- validIndex(PROGRAM, INDEX), NEXT_INDEX is INDEX + ARG, NEXT_FIXED is FIXED + 1.
evalInstr(PROGRAM, instr{op : "jmp", arg: _}, INDEX, ACC, FIXED, NEXT_INDEX, ACC, NEXT_FIXED) :- validIndex(PROGRAM, INDEX), NEXT_INDEX is INDEX + 1, NEXT_FIXED is FIXED + 1.
executeInstr(_, INDEX, _, _, _, VISITED) :- member(INDEX, VISITED), !, false.
executeInstr(PROGRAM, INDEX, ACC, FIXED, ACC, _) :- FIXED =< 1, length(PROGRAM, LENGTH), INDEX =:= LENGTH, !.
executeInstr(PROGRAM, INDEX, ACC, FIXED, RESULT, VISITED) :-
  FIXED =< 1,
  instrAtIndex(PROGRAM, INDEX, INSTR),
  evalInstr(PROGRAM, INSTR, INDEX, ACC, FIXED, NEXT_INDEX, NEXT_ACC, NEXT_FIXED),
  executeInstr(PROGRAM, NEXT_INDEX, NEXT_ACC, NEXT_FIXED, RESULT, [INDEX|VISITED]).

execute(PROGRAM, RESULT) :- executeInstr(PROGRAM, 0, 0, 0, RESULT, []).

solve(FILE) :- ['lib/loadData.prolog'], loadData(PROGRAM, FILE), execute(PROGRAM, RESULT), write(RESULT).
solve :- solve('input/8.data').

/* required for loadData */
data_line(instr{op: OP, arg: ARG}, LINE) :- split_string(LINE, " ", "", [OP, ARG_STR]), number_string(ARG, ARG_STR).