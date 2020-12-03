valid(MIN, MAX, _, []) :- 0 >= MIN, MAX >= 0.
valid(MIN, MAX, CHAR, [CHAR|OTHER_CHARS]) :- valid(MIN - 1, MAX - 1, CHAR, OTHER_CHARS).
valid(MIN, MAX, CHAR, [FIRST_CHAR|OTHER_CHARS]) :- not(FIRST_CHAR = CHAR), valid(MIN, MAX, CHAR, OTHER_CHARS).
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