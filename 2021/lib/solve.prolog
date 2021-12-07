/* the user has to define data_line(RAW_DATA, PARSED_DATA) which converts a string into parsed data */
use_module(library(pio)).
byteLines([])                       --> call(eos), !.
byteLines([FIRST_LINE|OTHER_LINES]) --> byteLine(FIRST_LINE), byteLines(OTHER_LINES).
eos([], []).
byteLine([])                        --> ( "\n" ; call(eos) ), !.
byteLine([FIRST_BYTE|OTHER_BYTES])  --> [FIRST_BYTE], byteLine(OTHER_BYTES).
readByteLines(FILE, BYTELISTS) :- phrase_from_file(byteLines(BYTELISTS), FILE).

stringList_codesList([], []) :- !.
stringList_codesList([SH|ST], [CH|CT]) :- string_codes(SH, CH), stringList_codesList(ST, CT).
readLines(FILE, LINES) :- readByteLines(FILE, BYTELISTS), stringList_codesList(LINES, BYTELISTS).

loadData_(GROUPED_DATA, FILE) :- current_predicate(groupData/0), !, readLines(FILE, LINES), groupLines(LINES, GROUPED_LINES), groupedData_groupedLines(GROUPED_DATA, GROUPED_LINES).
loadData_(DATA, FILE) :- readLines(FILE, LINES), data_lines(DATA, LINES).

loadData(DATA, FILE) :- exists_file(FILE), !, loadData_(DATA, FILE).
loadData([], FILE) :- write("\nERROR! File "), write(FILE), write(" does not exists").
loadData(DATA) :- day(DAY), fileForDay(DAY, '.data', FILE), loadData(DATA, FILE).
loadTestData(DATA) :- day(DAY), fileForDay(DAY, '.test', FILE), loadData(DATA, FILE).

fileForDay(DAY, EXT, FILE) :- string_concat('input/', DAY, A), string_concat(A, EXT, FILE).

data_lines([], []).
data_lines([FIRST_DATA|OTHER_DATA], [FIRST_LINE|OTHER_LINES]) :- data_line(FIRST_DATA, FIRST_LINE), data_lines(OTHER_DATA, OTHER_LINES).

groupLines([""], [[]]) :- !.
groupLines([LINE1], [[LINE1]]) :- !.
groupLines([""|OTHER_LINES], [[]|GROUPED_OTHER_LINES]) :- !, groupLines(OTHER_LINES, GROUPED_OTHER_LINES).
groupLines([LINE1|OTHER_LINES], [[LINE1|GROUPED_OTHER_LINES_HEAD]|GROUPED_OTHER_LINES_TAIL]) :- groupLines(OTHER_LINES, [GROUPED_OTHER_LINES_HEAD|GROUPED_OTHER_LINES_TAIL]).

groupedData_groupedLines([HEADER_DATA|GROUPED_DATA], [[HEADER_LINE]|GROUPED_LINES]) :- current_predicate(data_header/2), !, data_header(HEADER_DATA, HEADER_LINE), groupedData_groupedLines_(GROUPED_DATA, GROUPED_LINES).
groupedData_groupedLines(GROUPED_DATA, GROUPED_LINES) :- groupedData_groupedLines_(GROUPED_DATA, GROUPED_LINES).
groupedData_groupedLines_([], []).
groupedData_groupedLines_([GROUPED_DATA_H|GROUPED_DATA_T], [GROUPED_LINES_H|GROUPED_LINES_T]) :-
  data_lines(GROUPED_DATA_H, GROUPED_LINES_H),
  groupedData_groupedLines_(GROUPED_DATA_T, GROUPED_LINES_T).

debugOut(NAME, DATA) :- current_predicate(debugOn/0), !, write(NAME), write(": "), write(DATA), write("\n\n").
debugOut(_, _).

printResult :- testResult(TEST_RESULT), loadTestData(TEST_DATA), result(TEST_DATA, TEST_RESULT), !, loadData(DATA), result(DATA, RESULT), write(RESULT).
printResult :- testResult(TEST_RESULT), loadTestData(TEST_DATA), debugOut("testData", TEST_DATA), result(TEST_DATA, WRONG_RESULT), !, write("\nFAIL! Test returned "), write(WRONG_RESULT), write(" instead of "), write(TEST_RESULT).
printResult :- loadTestData(TEST_DATA), loadData(DATA), !, debugOut("testData", TEST_DATA), debugOut("data", DATA), write("\nFAIL! No solution found").
printResult :- loadTestData(TEST_DATA), !, debugOut("testData", TEST_DATA), write("\nFAIL! Could not load data").
printResult :- write("\nFAIL! Could not load test data").

/* solve shortcuts */
solveDay(DAY) :- string_concat('input/', DAY, A), string_concat(A, '.data', RIDDLE), solve(RIDDLE).
solveTestDay(DAY) :- string_concat('input/', DAY, A), string_concat(A, '.test', RIDDLE), solve(RIDDLE).
solveTestDay(DAY, N) :- string_concat('input/', DAY, A), string_concat(A, '.test', B), string_concat(B, N, RIDDLE), solve(RIDDLE).
