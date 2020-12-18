valid(FIELD_VAL, [r{min:MIN, max: MAX}|_]) :- between(MIN, MAX, FIELD_VAL), !.
valid(FIELD_VAL, [_|RANGES]) :- valid(FIELD_VAL, RANGES).

validField(FIELD_VAL, [def{f: NAME, r: RANGES}|OTHER_DEFINITIONS], NAME, OTHER_DEFINITIONS) :- valid(FIELD_VAL, RANGES), !.
validField(FIELD_VAL, [DEFSh|DEFSt], NAME, [DEFSh|OTHER_DEFINITIONS]) :- validField(FIELD_VAL, DEFSt, NAME, OTHER_DEFINITIONS).

validTicket(ticket{fields: []}, []).
validTicket(ticket{fields: [H|T]}, DEFINITIONS) :- validField(H, DEFINITIONS, _, OTHER_DEFINITIONS), validTicket(ticket{fields: T}, OTHER_DEFINITIONS).

discardInvalidTickets([], [], _).
discardInvalidTickets([H|T], [H|Tn], DEFINITIONS) :- validTicket(H, DEFINITIONS), !, discardInvalidTickets(T, Tn, DEFINITIONS).
discardInvalidTickets([_|T], Tn, DEFINITIONS) :- discardInvalidTickets(T, Tn, DEFINITIONS).

allTicketsFirstFieldsAreValid(_, [], []).
allTicketsFirstFieldsAreValid(def{f: NAME, r: RANGES}, [ticket{fields: [H|T]}|TICKETS], [ticket{fields: T}|TICKETS_WO_FIRST_FIELD]) :-
  valid(H, RANGES),
  allTicketsFirstFieldsAreValid(def{f: NAME, r: RANGES}, TICKETS, TICKETS_WO_FIRST_FIELD).

findDefinitionForFirstField([def{f: NAME, r: RANGES}|T], TICKETS, T, TICKETS_WO_FIELD, NAME) :-
  allTicketsFirstFieldsAreValid(def{f: NAME, r: RANGES}, TICKETS, TICKETS_WO_FIELD).
findDefinitionForFirstField([H|T], TICKETS, [H|To], TICKETS_WO_FIELD, FIELD_NAME) :-
  findDefinitionForFirstField(T, TICKETS, To, TICKETS_WO_FIELD, FIELD_NAME).

removeFirstField([], []).
removeFirstField([ticket{fields: [_|T]}|OTHER_TICKETS], [ticket{fields: T}|OTHER_TICKETS_T]) :-
  removeFirstField(OTHER_TICKETS, OTHER_TICKETS_T).

findAllPossibleDefinitionsForFirstField([], _, []).
findAllPossibleDefinitionsForFirstField([def{f: NAME, r: RANGES}|T], TICKETS, [NAME|OTHER_NAMES]) :-
  allTicketsFirstFieldsAreValid(def{f: NAME, r: RANGES}, TICKETS, _), !,
  findAllPossibleDefinitionsForFirstField(T, TICKETS, OTHER_NAMES).
findAllPossibleDefinitionsForFirstField([_|T], TICKETS, OTHER_NAMES) :-
  findAllPossibleDefinitionsForFirstField(T, TICKETS, OTHER_NAMES).

findAllPossibleDefinitionsForAllFields(_, [ticket{fields: []}|_], []) :- !.
findAllPossibleDefinitionsForAllFields(DEFINITIONS, TICKETS, [FIELD_NAMES|OTHER_FIELD_NAMES]) :-
  findAllPossibleDefinitionsForFirstField(DEFINITIONS, TICKETS, FIELD_NAMES),
  removeFirstField(TICKETS, TICKETS_WO_FIRST_FIELD),
  findAllPossibleDefinitionsForAllFields(DEFINITIONS, TICKETS_WO_FIRST_FIELD, OTHER_FIELD_NAMES).

removeField(_, [], []).
removeField(FIELD, [FIELD|T], T) :- !.
removeField(FIELD, [H|T], [H|T_WO]) :- removeField(FIELD, T, T_WO).

removeFieldL(_, [], []).
removeFieldL(FIELD, [[Hh|Ht]|T], [Hr|Tr]) :-
  removeField(FIELD, [Hh|Ht], Hr),
  removeFieldL(FIELD, T, Tr).

combine([], []).
combine([FIELDS_H|FIELDS_T], [FIELD|COMBINATION_T]) :-
  member(FIELD, FIELDS_H),
  removeFieldL(FIELD, FIELDS_T, OTHER_FIELDS),
  combine(OTHER_FIELDS, COMBINATION_T).
  
fieldOrder(DEFINITIONS, TICKETS, FIELD_ORDER) :-
  findAllPossibleDefinitionsForAllFields(DEFINITIONS, TICKETS, POSSIBLE_FIELDS),
  combine(POSSIBLE_FIELDS, FIELD_ORDER).

isDepartureField(FIELD) :- sub_string(FIELD, 0, _, _, "departure").

getDepartureFields(ticket{fields: []}, _, []).
getDepartureFields(ticket{fields: [FIRST_VAL|OTHER_VALS]}, [FIRST_FIELD|OTHER_FIELDS], [FIRST_VAL|T]) :-
  isDepartureField(FIRST_FIELD), !,
  getDepartureFields(ticket{fields: OTHER_VALS}, OTHER_FIELDS, T).
getDepartureFields(ticket{fields: [_|OTHER_VALS]}, [_|OTHER_FIELDS], T) :-
  getDepartureFields(ticket{fields: OTHER_VALS}, OTHER_FIELDS, T).

multiply([], 1).
multiply([H|T], P) :- multiply(T, Pt), P is H * Pt.

solve(FILE) :-
  loadFile(FILE, DEFINITIONS, MY_TICKET, NEARBY_TICKETS),
  discardInvalidTickets(NEARBY_TICKETS, VALID_TICKETS, DEFINITIONS),
  fieldOrder(DEFINITIONS, VALID_TICKETS, FIELD_ORDER),
  getDepartureFields(MY_TICKET, FIELD_ORDER, DEPARTURE_FIELDS),
  multiply(DEPARTURE_FIELDS, PRODUCT),
  write(PRODUCT).
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