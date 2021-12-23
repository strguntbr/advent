/* the user has to define data_line(RAW_DATA, PARSED_DATA) which converts a string into parsed data */
use_module(library(pio)).

byteLines([])                     --> call(eos), !.
byteLines([FirstLine|OtherLines]) --> byteLine(FirstLine), byteLines(OtherLines).
eos([], []).
byteLine([])                      --> ( "\n" ; call(eos) ), !.
byteLine([FirstByte|OtherBytes])  --> [FirstByte], byteLine(OtherBytes).
readByteLines(File, ByteLists) :- phrase_from_file(byteLines(ByteLists), File).
readLines(File, Lines) :- readByteLines(File, ByteLists), maplist(string_codes, Lines, ByteLists).

loadData_(GroupedData, File) :-
  current_predicate(groupData/0), !,
  p_resetData, readLines(File, Lines),
  groupLines(Lines, GroupedLines), groupedData_groupedLines(GroupedData, GroupedLines).
loadData_(Data, File) :- p_resetData, readLines(File, Lines), data_lines(Data, Lines).

loadData(Data, File, []) :- exists_file(File), !, loadData_(Data, File).
loadData([], File, Error) :- format(string(Error), 'File ~w does not exist', [File]).
loadTestData(Data) :- p_day(Day), fileForDay(Day, 'test', File), loadData(Data, File, Error), (
    Error \= [] -> writeln(Error), fail
    ; true
  ).

fileForDay(Day, Extension, File) :- format(atom(File), 'input/~w.~w', [Day, Extension]).

data_lines(Data, Lines) :- maplist(p_data_line, Data, Lines).

groupLines([""], [[]]) :- !.
groupLines([Line1], [[Line1]]) :- !.
groupLines([""|OtherLines], [[]|GroupedOtherLines]) :- !, groupLines(OtherLines, GroupedOtherLines).
groupLines([Line1|OtherLines], [[Line1|GroupedOtherLinesHead]|GroupedOtherLinesTail]) :- groupLines(OtherLines, [GroupedOtherLinesHead|GroupedOtherLinesTail]).

groupedData_groupedLines([HeaderData|GroupedData], [[HeaderLine]|GroupedLines]) :- 
  current_predicate(data_header/2), !, data_header(HeaderData, HeaderLine), groupedData_groupedLines_(GroupedData, GroupedLines).
groupedData_groupedLines(GroupedData, GroupedLines) :- groupedData_groupedLines_(GroupedData, GroupedLines).
groupedData_groupedLines_(GroupedData, GroupedLines) :- maplist(data_lines, GroupedData, GroupedLines).

solve :- printResult.

printResult :- verifyTests, printResultWithoutTest.
printResultWithoutTest :- getData(Data), executePuzzle(Data).

getData(Data) :- p_day(Day), fileForDay(Day, 'data', File), loadData(Data, File, Error), !, checkLoadError(Error).
getData(_) :- writeln('Error: Could not load puzzle data'), halt(5).
checkLoadError([]) :- !.
checkLoadError(Error) :- format('Error: ~w', [Error]), halt(6).
executePuzzle(Data) :- p_result(Data, Result), !, (p_hideResult -> FormattedResult = "" ; white(Result, FormattedResult)), format('Result is ~w', [FormattedResult]), p_finalize(Result).
executePuzzle(_) :- writeln('Error: could find result for puzzle data'), halt(7).

testResult_(File, ExpectedResult) :- p_testResult(ExpectedResult), p_day(Day), fileForDay(Day, 'test', File).
testResult_(File, ExpectedResult) :- p_testResult(Extension, ExpectedResult), p_day(Day), format(atom(File), 'input/~w.~w', [Day, Extension]).
findTests(Tests) :- findall([File, ExpectedResult], testResult_(File, ExpectedResult), Tests).

verifyTests :- current_predicate(skipTest/0), !, testSkipped(Status), format('[~w] ', [Status]).
verifyTests :- p_initDynamicTests, forall(testResult_(FILE, ExpectedResult), verifyTest(FILE, ExpectedResult)), testPassed(Status), format('[~w] ', [Status]).

verifyTest(File, ExpectedResult) :- getTestData(File, TestData), executeTest(File, TestData, ExpectedResult).
getTestData(File, TestData) :- loadData(TestData, File, Error), !, checkTestLoadError(Error).
getTestData(File, _) :- testFailed(Status), format('[~w] Could not load test data ~w', [Status, File]), halt(1).
checkTestLoadError([]) :- !.
checkTestLoadError(Error) :- testFailed(Status), format('[~w] ~w', [Status, Error]), halt(2).
executeTest(File, TestData, ExpectedResult) :- p_result(TestData, TestResult), !, verifyResult(File, TestResult, ExpectedResult).
executeTest(File, _, _) :- testFailed(Status), format('[~w] No solution for test data ~w found', [Status, File]), halt(3).
verifyResult(_, TestResult, TestResult) :- !.
verifyResult(File, WrongResult, ExpectedResult) :- testFailed(Status), format("[~w] Test ~w returned ~w instead of ~w", [Status, File, WrongResult, ExpectedResult]), halt(4).

testPassed(Text) :- green('TEST  PASSED', Text).
testFailed(Text) :- red('TEST  FAILED', Text).
testSkipped(Text) :- yellow('TEST SKIPPED', Text).

/* ANSI XTERM utlitly methods */
green(Text, ColoredText) :- isAnsiXterm, !, format(atom(ColoredText), '\033[0;32m~w\033[0m', [Text]).
green(Text, Text).
red(Text, ColoredText) :- isAnsiXterm, !, format(atom(ColoredText), '\033[0;31m~w\033[0m', [Text]).
red(Text, Text).
yellow(Text, ColoredText) :- isAnsiXterm, !, format(atom(ColoredText), '\033[0;33m~w\033[0m', [Text]).
yellow(Text, Text).
white(Text, ColoredText) :- isAnsiXterm, !, format(atom(ColoredText), '\033[1;37m~w\033[0m', [Text]).
white(Text, Text).

moveCursor(Distance, Direction) :- isAnsiXterm -> moveCursor_(Distance, Direction) ; true.
moveCursor_(0, _) :- !.
moveCursor_(Distance, 'up') :- format('\033[~dA', [Distance]).
moveCursor_(Distance, 'down') :- format('\033[~dB', [Distance]).
moveCursor_(Distance, 'right') :- format('\033[~dC', [Distance]).
moveCursor_(Distance, 'left') :- format('\033[~dD', [Distance]).

cursorPosition(Position) :-
  isAnsiXterm,
  csi('[6n'), readResponse(Response), !,
  string_codes(ResponseStr, Response),
  split_string(ResponseStr, ";", "", [_, PosStr]),
  number_codes(Position, PosStr).
cursorPosition(0).

readResponse(Response) :-
  get_single_char(C),
  (
    data(C) -> readResponse(ResponseN), Response = [C|ResponseN] 
    ; startCode(C) -> readResponse(Response)
    ; Response = []
  ).

data(C) :- digit(C) ; semicolon(C).
digit(C) :- between(48, 57, C).
semicolon(59).
startCode(27). startCode(91).

csi(Sequence) :- isAnsiXterm -> format('\033~w', [Sequence]) ; true.
csi(Target, Sequence) :- isAnsiXterm -> format(Target, '\033~w', [Sequence]) ; format(Target, '', []).

isAnsiXterm :- stream_property(current_output, tty(true)), current_prolog_flag(color_term, true).

/* proxies for methods defined outside this  file */
p_day(Day) :- day(Day).
p_resetData :- current_predicate(resetData/0) -> resetData ; true.
p_data_line(Data, Line) :- data_line(Data, Line).
p_result(Data, Result) :- result(Data, Result).
p_testResult(ExpectedResult) :- current_predicate(testResult/1), testResult(ExpectedResult).
p_testResult(Extension, ExpectedResult) :- current_predicate(testResult/2), testResult(Extension, ExpectedResult).
p_finalize(Result) :- current_predicate(finalize/1) -> finalize(Result) ; true.
p_initDynamicTests :- current_predicate(initDynamicTests/0) -> initDynamicTests ; true.
p_hideResult :- current_predicate(hideResult/0).