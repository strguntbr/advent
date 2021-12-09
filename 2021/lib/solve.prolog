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

loadData(DATA, FILE, []) :- exists_file(FILE), !, loadData_(DATA, FILE).
loadData([], FILE, ERROR) :- format(string(ERROR), "File ~w does not exist", [FILE]).
loadData(DATA, ERROR) :- day(DAY), fileForDay(DAY, '.data', FILE), loadData(DATA, FILE, ERROR).
loadTestData(DATA, ERROR) :- day(DAY), fileForDay(DAY, '.test', FILE), loadData(DATA, FILE, ERROR).

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

printResult :- current_predicate(skipTest/0), !, write("[TEST SKIPPED] "), printResultWithoutTest.
printResult :- verifyTest, printResultWithoutTest.

printResultWithoutTest :- getData(DATA), execute(DATA).
getData(DATA) :- loadData(DATA, ERROR), !, checkLoadError(ERROR).
getData(_) :- writeln("Error: Could not load riddle data"), halt(5).
checkLoadError([]) :- !.
checkLoadError(ERROR) :- loadData(_, ERROR), !, format("Error: ~w~n", [ERROR]), halt(6).
execute(DATA) :- result(DATA, RESULT), !, format("Result is ~w~n", [RESULT]).
execute(_) :- writeln("Error: could find result for riddle data"), halt(7).

verifyTest :- getTestData(TEST_DATA), executeTest(TEST_DATA).
getTestData(TEST_DATA) :- loadTestData(TEST_DATA, ERROR), !, checkTestLoadError(ERROR).
getTestData(_) :- writeln("[TEST  FAILED] Could not load test data"), halt(1).
checkTestLoadError([]) :- !.
checkTestLoadError(ERROR) :- format("[TEST  FAILED] ~w~n", [ERROR]), halt(2).
executeTest(TEST_DATA) :- result(TEST_DATA, TEST_RESULT), !, verifyResult(TEST_RESULT).
executeTest(_) :- writeln("[TEST  FAILED] No solution for test data found"), halt(3).
verifyResult(TEST_RESULT) :- testResult(TEST_RESULT), !, write("[TEST  PASSED] ").
verifyResult(WRONG_RESULT) :- testResult(TEST_RESULT), format("[TEST  FAILED] Test returned ~w instead of ~w~n", [WRONG_RESULT, TEST_RESULT]), halt(4).