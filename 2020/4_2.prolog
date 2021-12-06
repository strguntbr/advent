removeValidFromList([kvp{key:KEY, value:VALUE}|LIST_WITHOUT_KVP], KEY, LIST_WITHOUT_KVP) :- !, validKvp(KEY, VALUE).
removeValidFromList([FIRST_ITEM|OTHER_ITEMS], SINGLE_ITEM, [FIRST_ITEM|LIST_WITHOUT_ITEM]) :- removeValidFromList(OTHER_ITEMS, SINGLE_ITEM, LIST_WITHOUT_ITEM).
containsAllFields([], _) :- !.
containsAllFields([FIRST_REQUIRED_FIELD|OTHER_REQUIRED_FIELDS], KVPS) :- removeValidFromList(KVPS, FIRST_REQUIRED_FIELD, OTHER_KVPS), containsAllFields(OTHER_REQUIRED_FIELDS, OTHER_KVPS).
validPassport(PASSPORT) :- requiredFields(REQUIRED_FIELDS), containsAllFields(REQUIRED_FIELDS, PASSPORT).

countValid(PASSPORT, OLD_COUNT, NEW_COUNT) :- validPassport(PASSPORT), !, NEW_COUNT is OLD_COUNT+1.
countValid(_, COUNT, COUNT).

validPassports(0, []) :- !.
validPassports(COUNT, [FIRST_PASSPORT|OTHER_PASSPORTS]) :- validPassports(OTHER_COUNT, OTHER_PASSPORTS), countValid(FIRST_PASSPORT, OTHER_COUNT, COUNT).

requiredFields(["byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid"]).

validKvp("byr", VALUE) :- !, number_string(YEAR, VALUE), YEAR >= 1920, YEAR =< 2002.
validKvp("iyr", VALUE) :- !, number_string(YEAR, VALUE), YEAR >= 2010, YEAR =< 2020.
validKvp("eyr", VALUE) :- !, number_string(YEAR, VALUE), YEAR >= 2020, YEAR =< 2030.
validKvp("hgt", VALUE) :- !, validHgt(VALUE).
validKvp("hcl", VALUE) :- !, isColor(VALUE).
validKvp("ecl", VALUE) :- !, validEcl(VALUE).
validKvp("pid", VALUE) :- !, string_chars(VALUE, DIGITS), countDigits(DIGITS, 9).
validKvp(_, _).
validEcl("amb"). validEcl("blu"). validEcl("brn"). validEcl("gry"). validEcl("grn"). validEcl("hzl"). validEcl("oth").
countDigits([], 0) :- !.
countDigits([H|T], LENGTH) :- digit(H), countDigits(T, TLENGTH), LENGTH is TLENGTH + 1.
digit('0'). digit('1'). digit('2'). digit('3'). digit('4'). digit('5'). digit('6'). digit('7'). digit('8'). digit('9').
validHgt(VALUE) :- sub_string(VALUE, L, 2, 0, UNIT), sub_string(VALUE, 0, L, _, HEIGHT_STR), number_string(HEIGHT, HEIGHT_STR), validHgt(HEIGHT, UNIT).
validHgt(HEIGHT, "cm") :- !, HEIGHT >= 150, HEIGHT =< 193.
validHgt(HEIGHT, "in") :- !, HEIGHT >= 59, HEIGHT =< 76.
isColor(VALUE) :- string_chars(VALUE, ['#'|CHARS]), hexBytes(CHARS, 3).
hexBytes([], 0).
hexBytes([FIRST_NIBBLE|OTHER_NIBBLES], COUNT) :- hexChar(FIRST_NIBBLE), hexByteHalf(OTHER_NIBBLES, COUNT).
hexByteHalf([FIRST_NIBBLE|OTHER_NIBBLES], COUNT) :- hexChar(FIRST_NIBBLE), hexBytes(OTHER_NIBBLES, OTHER_COUNT), COUNT is OTHER_COUNT+1.
hexChar('a'). hexChar('b'). hexChar('c'). hexChar('d'). hexChar('e'). hexChar('f'). hexChar(CHAR) :- digit(CHAR).

solve(FILE) :- ['lib/loadData.prolog'], loadPreprocessedData(PASSPORTS, FILE), validPassports(COUNT, PASSPORTS), write(COUNT).
solve :- solve('input/4.data').

/* required for loadData */
data_line(PASSPORTS, LINE) :- split_string(LINE, " ", "", SPLIT_LINE), parseKvps(SPLIT_LINE, PASSPORTS).
parseKvps([], []).
parseKvps([FIRST_INPUT|OTHER_INPUT], [FIRST_KVP|OTHER_KVPS]) :- parseKvp(FIRST_INPUT, FIRST_KVP), parseKvps(OTHER_INPUT, OTHER_KVPS).
parseKvp(INPUT, kvp{key: KEY, value: VALUE}) :- split_string(INPUT, ":", "", [KEY, VALUE]).
/* required for loadPreprocessedData */
preprocessLines(LINE1, [], [LINE1]) :- !.
preprocessLines(LINE1, [""|OTHER_LINES], [LINE1|OTHER_PREPROCESSED_LINES]) :- !, preprocessLines(OTHER_LINES, OTHER_PREPROCESSED_LINES).
preprocessLines(LINE1, [LINE2|OTHER_LINES], PREPROCESSED_LINES) :- mergeLines(LINE1, LINE2, MERGED_LINE), preprocessLines(MERGED_LINE, OTHER_LINES, PREPROCESSED_LINES).
preprocessLines([], []).
preprocessLines([LINE1|OTHER_LINES], PREPROCESSED_LINES) :- preprocessLines(LINE1, OTHER_LINES, PREPROCESSED_LINES).
mergeLines(LINE1, LINE2, MERGED_LINE) :- string_concat(LINE1, " ", LINE1_WITH_SEPARATOR), string_concat(LINE1_WITH_SEPARATOR, LINE2, MERGED_LINE).