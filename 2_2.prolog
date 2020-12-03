valid(_, 0, _, _) :- false, !.
valid(_, 1, FIRST_CHAR, [FIRST_CHAR|_]) :- true, !.
valid(1, MIN, FIRST_CHAR, [FIRST_CHAR|OTHER_CHARS]) :- !, NEW_MIN is MIN - 1, not(valid(0, NEW_MIN, FIRST_CHAR, OTHER_CHARS)).
valid(MIN, MAX, CHAR, [_|OTHER_CHARS]) :- NEW_MIN is MIN - 1, NEW_MAX is MAX - 1, valid(NEW_MIN, NEW_MAX, CHAR, OTHER_CHARS).
validPassword(RULE, PASSWORD) :- string_chars(PASSWORD, CHARS), valid(RULE.min, RULE.max, RULE.char, CHARS).

countValid(RULE, PASSWORD, OLD_COUNT, NEW_COUNT) :- validPassword(RULE, PASSWORD), !, NEW_COUNT is OLD_COUNT+1.
countValid(_, _, COUNT, COUNT).

validPasswords(0, []) :- !.
validPasswords(COUNT, [FIRST_DATA|OTHER_DATA]) :- validPasswords(OTHER_COUNT, OTHER_DATA), countValid(FIRST_DATA.rule, FIRST_DATA.password, OTHER_COUNT, COUNT).

solve(FILE) :- ['lib/loadData.prolog'], loadData(DATA, FILE), validPasswords(COUNT, DATA), write(COUNT).
solve :- solve('input/2.data').

/* required for loadData */
data_line(data{rule: rule{min: MIN, max: MAX, char: CHAR}, password: PASSWORD}, LINE) :-
    split_string(LINE, ":", " ", [RULE, PASSWORD]),
    split_string(RULE, " ", "", [RANGE, CHAR_STR]), atom_string(CHAR, CHAR_STR),
    split_string(RANGE, "-", "", [MIN_STR, MAX_STR]), number_string(MIN, MIN_STR), number_string(MAX, MAX_STR).