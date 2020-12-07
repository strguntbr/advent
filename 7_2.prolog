countBags(BAG_SPECS, color{var: VARIANT, col: COLOR}, COUNT) :- 
  member(edges{from: color{var: VARIANT, col: COLOR}, tos: TOS}, BAG_SPECS),
  countBagsList(BAG_SPECS, TOS, COUNT_INSIDE),
  COUNT is 1 + COUNT_INSIDE.
countBagsList(_, [], 0) :- !.
countBagsList(BAG_SPECS, [bags{cnt: H_CNT, var: H_VAR, col: H_COL}|T], COUNT) :- 
  countBags(BAG_SPECS, color{var: H_VAR, col: H_COL}, COUNT2),
  countBagsList(BAG_SPECS, T, COUNT_T),
  COUNT is H_CNT * COUNT2 + COUNT_T.

solve(FILE) :- ['lib/loadData.prolog'], loadData(EDGES, FILE), countBags(EDGES, color{var:"shiny", col:"gold"}, COUNT), COUNT_WO_OUTER is COUNT - 1, write(COUNT_WO_OUTER).
solve :- solve('input/7.data').

/* required for loadData */
data_line(edges{from: color{var: OUTER_VARIANT, col: OUTER_COLOR}, tos: INNER_BAGS}, LINE) :- 
  specString_outerInnerBags(LINE, OUTER_BAG_STR, INNER_BAGS_STR),
  parseBag(OUTER_BAG_STR, bags{cnt: _, var: OUTER_VARIANT, col: OUTER_COLOR}),
  parseBags(INNER_BAGS_STR, INNER_BAGS).
specString_outerInnerBags(SPEC_STR, OUTER_BAG_STR, INNER_BAG_STR) :-
  sub_string(SPEC_STR, OUTER_L, _, INNER_L, " contain "),
  sub_string(SPEC_STR, 0, OUTER_L, _, OUTER_BAG_STR),
  sub_string(SPEC_STR, _, INNER_L, 0, INNER_BAG_STR).
parseBag(BAG_STR, bags{cnt: 1, var:VARIANT, col:COLOR}) :- split_string(BAG_STR, " ", "", [VARIANT, COLOR, _]).
parseBag(BAG_STR, bags{cnt: COUNT, var:VARIANT, col:COLOR}) :- split_string(BAG_STR, " ", "", [COUNT_STR, VARIANT, COLOR, _]), number_string(COUNT, COUNT_STR).
parseBags(BAGS_STR, BAGS) :-
  split_string(BAGS_STR, ",", " ", BAG_STRS),
  bagStrList_bagList(BAG_STRS, BAGS).
bagStrList_bagList(["no other bags."], []) :- !.
bagStrList_bagList([], []).
bagStrList_bagList([STR_H|STR_T], [BAGS_H|BAGS_T]) :- parseBag(STR_H, BAGS_H), bagStrList_bagList(STR_T, BAGS_T).