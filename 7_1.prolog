existsPath(EDGES, FROM, TO, _) :- member(edges{from: FROM, tos: TOS}, EDGES), member(TO, TOS), !.
existsPath(EDGES, FROM, TO, VISITED) :- not(member(FROM, VISITED)), member(edges{from: FROM, tos: VIAS}, EDGES), member(VIA, VIAS), existsPath(EDGES, VIA, TO, [FROM|VISITED]), !.

pathWithStart(EDGES, FROM, TO) :- member(edges{from: FROM, tos: TOS}, EDGES), member(TO, TOS).
pathWithStart(EDGES, FROM, TO) :- member(edges{from: FROM, tos: VIAS}, EDGES), member(VIA, VIAS), existsPath(EDGES, VIA, TO, [FROM]).

countOuterBags(EDGES, INNER_BAG, COUNT) :- aggregate_all(count, OUTER_BAG, pathWithStart(EDGES, OUTER_BAG, INNER_BAG), COUNT).

solve(FILE) :- ['lib/loadData.prolog'], loadData(EDGES, FILE), countOuterBags(EDGES, color{var:"shiny", col:"gold"}, COUNT), write(COUNT).
solve :- solve('input/7.data').

/* required for loadData */
data_line(edges{from: OUTER_BAG, tos: INNER_BAGS}, LINE) :- 
  specString_outerInnerBags(LINE, OUTER_BAG_STR, INNER_BAGS_STR),
  parseBag(OUTER_BAG_STR, OUTER_BAG),
  parseBags(INNER_BAGS_STR, INNER_BAGS).
specString_outerInnerBags(SPEC_STR, OUTER_BAG_STR, INNER_BAG_STR) :-
  sub_string(SPEC_STR, OUTER_L, _, INNER_L, " contain "),
  sub_string(SPEC_STR, 0, OUTER_L, _, OUTER_BAG_STR),
  sub_string(SPEC_STR, _, INNER_L, 0, INNER_BAG_STR).
parseBag(BAG_STR, color{var:VARIANT, col:COLOR}) :- split_string(BAG_STR, " ", "", [VARIANT, COLOR, _]).
parseBag(BAG_STR, color{var:VARIANT, col:COLOR}) :- split_string(BAG_STR, " ", "", [_, VARIANT, COLOR, _]).
parseBags(BAGS_STR, BAGS) :-
  split_string(BAGS_STR, ",", " ", BAG_STRS),
  bagStrList_bagList(BAG_STRS, BAGS).
bagStrList_bagList(["no other bags."], []) :- !.
bagStrList_bagList([], []).
bagStrList_bagList([STR_H|STR_T], [BAGS_H|BAGS_T]) :- parseBag(STR_H, BAGS_H), bagStrList_bagList(STR_T, BAGS_T).