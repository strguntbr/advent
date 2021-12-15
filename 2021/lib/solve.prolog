/* the user has to define data_line(RAW_DATA, PARSED_DATA) which converts a string into parsed data */
use_module(library(pio)).

byteLines([])                       --> call(eos), !.
byteLines([FIRST_LINE|OTHER_LINES]) --> byteLine(FIRST_LINE), byteLines(OTHER_LINES).
eos([], []).
byteLine([])                        --> ( "\n" ; call(eos) ), !.
byteLine([FIRST_BYTE|OTHER_BYTES])  --> [FIRST_BYTE], byteLine(OTHER_BYTES).
readByteLines(FILE, BYTELISTS) :- phrase_from_file(byteLines(BYTELISTS), FILE).
readLines(FILE, LINES) :- readByteLines(FILE, BYTELISTS), maplist(string_codes, LINES, BYTELISTS).

loadData_(GROUPED_DATA, FILE) :- current_predicate(groupData/0), !, p_resetData, readLines(FILE, LINES), groupLines(LINES, GROUPED_LINES), groupedData_groupedLines(GROUPED_DATA, GROUPED_LINES).
loadData_(DATA, FILE) :- p_resetData, readLines(FILE, LINES), data_lines(DATA, LINES).

loadData(DATA, FILE, []) :- exists_file(FILE), !, loadData_(DATA, FILE).
loadData([], FILE, ERROR) :- format(string(ERROR), "File ~w does not exist", [FILE]).
loadTestData(DATA) :- p_day(DAY), fileForDay(DAY, 'test', FILE), loadData(DATA, FILE, ERROR), (
    ERROR \= [] -> writeln(ERROR), fail
    ; true
  ).

fileForDay(DAY, EXT, FILE) :- format(atom(FILE), 'input/~w.~w', [DAY, EXT]).

data_lines(DATA, LINES) :- maplist(p_data_line, DATA, LINES).

groupLines([""], [[]]) :- !.
groupLines([LINE1], [[LINE1]]) :- !.
groupLines([""|OTHER_LINES], [[]|GROUPED_OTHER_LINES]) :- !, groupLines(OTHER_LINES, GROUPED_OTHER_LINES).
groupLines([LINE1|OTHER_LINES], [[LINE1|GROUPED_OTHER_LINES_HEAD]|GROUPED_OTHER_LINES_TAIL]) :- groupLines(OTHER_LINES, [GROUPED_OTHER_LINES_HEAD|GROUPED_OTHER_LINES_TAIL]).

groupedData_groupedLines([HEADER_DATA|GROUPED_DATA], [[HEADER_LINE]|GROUPED_LINES]) :- current_predicate(data_header/2), !, data_header(HEADER_DATA, HEADER_LINE), groupedData_groupedLines_(GROUPED_DATA, GROUPED_LINES).
groupedData_groupedLines(GROUPED_DATA, GROUPED_LINES) :- groupedData_groupedLines_(GROUPED_DATA, GROUPED_LINES).
groupedData_groupedLines_(GROUPED_DATA, GROUPED_LINES) :- maplist(data_lines, GROUPED_DATA, GROUPED_LINES).

printResult :- verifyTests, printResultWithoutTest.
printResultWithoutTest :- getData(DATA), execute(DATA).

getData(DATA) :- p_day(DAY), fileForDay(DAY, 'data', FILE), loadData(DATA, FILE, ERROR), !, checkLoadError(ERROR).
getData(_) :- writeln("Error: Could not load riddle data"), halt(5).
checkLoadError([]) :- !.
checkLoadError(ERROR) :- format("Error: ~w", [ERROR]), halt(6).
execute(DATA) :- p_result(DATA, RESULT), !, format("Result is ~w", [RESULT]), p_finalize.
execute(_) :- writeln("Error: could find result for riddle data"), halt(7).

testResult_(FILE, EXPECTED_RESULT) :- p_testResult(EXPECTED_RESULT), p_day(DAY), fileForDay(DAY, 'test', FILE).
testResult_(FILE, EXPECTED_RESULT) :- p_testResult(EXTENSION, EXPECTED_RESULT), p_day(DAY), format(atom(FILE), 'input/~w.~w', [DAY, EXTENSION]).
findTests(TESTS) :- findall([FILE, EXPECTED_RESULT], testResult_(FILE, EXPECTED_RESULT), TESTS).

verifyTests :- current_predicate(skipTest/0), !, testSkipped(STATUS), format('[~w] ', [STATUS]).
verifyTests :- forall(testResult_(FILE, EXPECTED_RESULT), verifyTest(FILE, EXPECTED_RESULT)), testPassed(STATUS), format('[~w] ', [STATUS]).

verifyTest(FILE, EXPECTED_RESULT) :- getTestData(FILE, TEST_DATA), executeTest(FILE, TEST_DATA, EXPECTED_RESULT).
getTestData(FILE, TEST_DATA) :- loadData(TEST_DATA, FILE, ERROR), !, checkTestLoadError(ERROR).
getTestData(FILE, _) :- testFailed(STATUS), format('[~w] Could not load test data ~w', [STATUS, FILE]), halt(1).
checkTestLoadError([]) :- !.
checkTestLoadError(ERROR) :- testFailed(STATUS), format("[~w] ~w", [STATUS, ERROR]), halt(2).
executeTest(FILE, TEST_DATA, EXPECTED_RESULT) :- p_result(TEST_DATA, TEST_RESULT), !, verifyResult(FILE, TEST_RESULT, EXPECTED_RESULT).
executeTest(FILE, _, _) :- testFailed(STATUS), format('[~w] No solution for test data ~w found', [STATUS, FILE]), halt(3).
verifyResult(_, TEST_RESULT, TEST_RESULT) :- !.
verifyResult(FILE, WRONG_RESULT, EXPECTED_RESULT) :- testFailed(STATUS), format("[~w] Test ~w returned ~w instead of ~w", [STATUS, FILE, WRONG_RESULT, EXPECTED_RESULT]), halt(4).

testPassed(TEXT) :- green("TEST  PASSED", TEXT).
testFailed(TEXT) :- red("TEST  FAILED", TEXT).
testSkipped(TEXT) :- yellow("TEST SKIPPED", TEXT).

/* ANSI XTERM utlitly methods */
green(TEXT, COLORED_TEXT) :- isAnsiXterm, !, format(atom(COLORED_TEXT), '\033[0;32m~w\033[0m', [TEXT]).
green(TEXT, TEXT).
red(TEXT, COLORED_TEXT) :- isAnsiXterm, !, format(atom(COLORED_TEXT), '\033[0;31m~w\033[0m', [TEXT]).
red(TEXT, TEXT).
yellow(TEXT, COLORED_TEXT) :- isAnsiXterm, !, format(atom(COLORED_TEXT), '\033[0;33m~w\033[0m', [TEXT]).
yellow(TEXT, TEXT).

moveCursor(DISTANCE, DIR) :- isAnsiXterm, !, D is DISTANCE, moveCursor_(D, DIR).
moveCursor(_, _).
moveCursor_(0, _) :- !.
moveCursor_(DISTANCE, 'up') :- format('\033[~dA', [DISTANCE]).
moveCursor_(DISTANCE, 'down') :- format('\033[~dB', [DISTANCE]).
moveCursor_(DISTANCE, 'right') :- format('\033[~dC', [DISTANCE]).
moveCursor_(DISTANCE, 'left') :- format('\033[~dD', [DISTANCE]).

cursorPosition(POS) :-
  isAnsiXterm,
  csi('[6n'), readResponse(RESPONSE), !,
  string_codes(RESPONSE_STR, RESPONSE),
  split_string(RESPONSE_STR, ";", "", [_, POS_STR]),
  number_codes(POS, POS_STR).
cursorPosition(0).

readResponse(RESPONSE) :-
  get_single_char(C),
  (
    data(C) -> readResponse(RESPONSEn), RESPONSE = [C|RESPONSEn] 
    ; startCode(C) -> readResponse(RESPONSE)
    ; RESPONSE = []
  ).

data(C) :- digit(C) ; semicolon(C).
digit(C) :- between(48, 57, C).
semicolon(59).
startCode(27). startCode(91).

csi(SEQUENCE) :- isAnsiXterm, !, format('\033~w', [SEQUENCE]).
csi(_).
csi(TARGET, SEQUENCE) :- isAnsiXterm, !, format(TARGET, '\033~w', [SEQUENCE]).
csi(TARGET, _) :- format(TARGET, '', []).

isAnsiXterm :- stream_property(current_output, tty(true)), current_prolog_flag(color_term, true).

/* proxies for methods defined outside this  file */
p_day(DAY) :- day(DAY).
p_resetData :- current_predicate(resetData/0) -> resetData ; true.
p_data_line(DATA, LINE) :- data_line(DATA, LINE).
p_result(DATA, RESULT) :- result(DATA, RESULT).
p_testResult(EXPECTED_RESULT) :- current_predicate(testResult/1), testResult(EXPECTED_RESULT).
p_testResult(EXTENSION, EXPECTED_RESULT) :- current_predicate(testResult/2), testResult(EXTENSION, EXPECTED_RESULT).
p_finalize :- current_predicate(finalize/0) -> finalize ; true.