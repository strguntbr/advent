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

loadData(DATA, FILE) :- readLines(FILE, LINES), data_lines(DATA, LINES).
data_lines([],[]).
data_lines([FIRST_DATA|OTHER_DATA], [FIRST_LINE|OTHER_LINES]) :- data_line(FIRST_DATA, FIRST_LINE), data_lines(OTHER_DATA, OTHER_LINES).