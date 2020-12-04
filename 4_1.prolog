removeFromList([kvp{key:KEY, value:_}|LIST_WITHOUT_KVP], KEY, LIST_WITHOUT_KVP) :- !.
removeFromList([FIRST_ITEM|OTHER_ITEMS], SINGLE_ITEM, [FIRST_ITEM|LIST_WITHOUT_ITEM]) :- removeFromList(OTHER_ITEMS, SINGLE_ITEM, LIST_WITHOUT_ITEM).
containsAllFields([], _) :- !.
containsAllFields([FIRST_REQUIRED_FIELD|OTHER_REQUIRED_FIELDS], KVPS) :- removeFromList(KVPS, FIRST_REQUIRED_FIELD, OTHER_KVPS), containsAllFields(OTHER_REQUIRED_FIELDS, OTHER_KVPS).
validPassport(PASSPORT) :- requiredFields(REQUIRED_FIELDS), containsAllFields(REQUIRED_FIELDS, PASSPORT).

countValid(PASSPORT, OLD_COUNT, NEW_COUNT) :- validPassport(PASSPORT), !, NEW_COUNT is OLD_COUNT+1.
countValid(_, COUNT, COUNT).

validPassports(0, []) :- !.
validPassports(COUNT, [FIRST_PASSPORT|OTHER_PASSPORTS]) :- validPassports(OTHER_COUNT, OTHER_PASSPORTS), countValid(FIRST_PASSPORT, OTHER_COUNT, COUNT).

requiredFields(["byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid"]).

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