validIndex(PROGRAM, INDEX) :- length(PROGRAM, L), between(0, L, INDEX).

instrAtIndex([INSTR1|_], 0, INSTR1) :- !.
instrAtIndex([_|REST_OF_PROGRAM], INDEX, INSTR) :- INDEX2 is INDEX - 1, instrAtIndex(REST_OF_PROGRAM, INDEX2, INSTR).

evalInstr(PROGRAM, instr{op : "nop", arg: _}, INDEX, ACC, NEXT_INDEX, ACC) :- validIndex(PROGRAM, INDEX), NEXT_INDEX is INDEX + 1.
evalInstr(PROGRAM, instr{op : "acc", arg: ARG}, INDEX, ACC, NEXT_INDEX, NEXT_ACC) :- validIndex(PROGRAM, INDEX), NEXT_INDEX is INDEX + 1, NEXT_ACC is ACC + ARG.
evalInstr(PROGRAM, instr{op : "jmp", arg: ARG}, INDEX, ACC, NEXT_INDEX, ACC) :- validIndex(PROGRAM, INDEX), NEXT_INDEX is INDEX + ARG.
executeInstr(_, INDEX, ACC, ACC, VISITED) :- member(INDEX, VISITED), !.
executeInstr(PROGRAM, INDEX, ACC, RESULT, VISITED) :-
  instrAtIndex(PROGRAM, INDEX, INSTR),
  evalInstr(PROGRAM, INSTR, INDEX, ACC, NEXT_INDEX, NEXT_ACC),
  executeInstr(PROGRAM, NEXT_INDEX, NEXT_ACC, RESULT, [INDEX|VISITED]).

execute(PROGRAM, RESULT) :- executeInstr(PROGRAM, 0, 0, RESULT, []).

solve(FILE) :- ['lib/loadData.prolog'], loadData(PROGRAM, FILE), execute(PROGRAM, RESULT), write(RESULT).
solve :- solve('input/8.data').

/* required for loadData */
data_line(instr{op: OP, arg: ARG}, LINE) :- split_string(LINE, " ", "", [OP, ARG_STR]), number_string(ARG, ARG_STR).