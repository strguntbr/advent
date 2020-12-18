
valid(FIELD_VAL, [r{min:MIN, max: MAX}|_]) :- between(MIN, MAX, FIELD_VAL), !.
valid(FIELD_VAL, [_|RANGES]) :- valid(FIELD_VAL, RANGES).

validField(FIELD_VAL, [def{f: NAME, r: RANGES}|OTHER_DEFINITIONS], NAME, OTHER_DEFINITIONS) :- valid(FIELD_VAL, RANGES).
validField(FIELD_VAL, [DEFSh|DEFSt], NAME, [DEFSh|OTHER_DEFINITIONS]) :- validField(FIELD_VAL, DEFSt, NAME, OTHER_DEFINITIONS).

sumInvalidFields(ticket{fields: []}, 0, _).
sumInvalidFields(ticket{fields: [H|T]}, SUM, DEFINITIONS) :- validField(H, DEFINITIONS, _, OTHER_DEFINITIONS), !, sumInvalidFields(ticket{fields: T}, SUM, OTHER_DEFINITIONS).
sumInvalidFields(ticket{fields: [H|T]}, SUM, DEFINITIONS) :- sumInvalidFields(ticket{fields: T}, SUMt, DEFINITIONS), plus(H, SUMt, SUM).

sumAllInvalidFields([], 0, _).
sumAllInvalidFields([H|T], SUM, DEFINITIONS) :- sumInvalidFields(H, SUMh, DEFINITIONS), sumAllInvalidFields(T, SUMt, DEFINITIONS), plus(SUMh, SUMt, SUM).

solve(FILE) :-
  loadFile(FILE, DEFINITIONS, _, NEARBY_TICKETS),
  sumAllInvalidFields(NEARBY_TICKETS, SUM, DEFINITIONS),
  write(SUM).
solveTest :- ['lib/loadData.prolog'], solveTestDay(16).
solveTest(N) :- ['lib/loadData.prolog'], solveTestDay(16, N).
solve :- ['lib/loadData.prolog'], solveDay(16).

loadFile(FILE, DEFINITIONS, MY_TICKET, NEARBY_TICKETS) :-
  loadData(DATA, FILE),
  definitions(DATA, DEFINITIONS, TICKET_DATA),
  tickets(TICKET_DATA, [MY_TICKET|NEARBY_TICKETS]).

definitions([[]|T], [], T).
definitions([def{f: FIELD, r: RANGES}|T], [def{f: FIELD, r: RANGES}|Td], TICKETS) :- definitions(T, Td, TICKETS).
tickets([], []).
tickets([[]|T], TICKETS) :- tickets(T, TICKETS).
tickets([ticket{fields: FIELDS}|T], [ticket{fields: FIELDS}|TICKETS]) :- tickets(T, TICKETS).

/* required for loadData */
data_line(def{f: FIELD, r: RANGES}, LINE) :-
  split_string(LINE, ":", " ", [FIELD, RANGE_STR]),
  split_string(RANGE_STR, "o", "r ", RANGE_STR_LIST),
  strings_ranges(RANGE_STR_LIST, RANGES).
data_line(ticket{fields: FIELDS}, LINE) :- split_string(LINE, ",", "", FIELD_STRS), numbers_strings(FIELDS, FIELD_STRS).
data_line([], "").
data_line([], "your ticket:").
data_line([], "nearby tickets:").

strings_ranges([], []).
strings_ranges([H|T], [Hr|Tr]) :- string_range(H, Hr), strings_ranges(T, Tr).
string_range(S, r{min:MIN, max: MAX}) :- split_string(S, "-", "", [MIN_STR, MAX_STR]), number_string(MIN, MIN_STR), number_string(MAX, MAX_STR).

numbers_strings([], []).
numbers_strings([H|T], [Hn|Tn]) :- number_string(H, Hn), numbers_strings(T, Tn).