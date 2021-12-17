:- include('lib/solve.prolog'). day(14). testResult(2188189693529). groupData.

result([[Template], Rules], Result) :-
  transformTemplate(Template, Pairs, Last), applyRulesMultipleTimes(Rules, Pairs, 40, AppliedPairs),
  minMaxSymbolCount(AppliedPairs, Last, Min, Max), Result is Max - Min.

minMaxSymbolCount(Pairs, LastSymbol, Min, Max) :-
  maplist(count, Pairs, NonUniqueCountData), aggregate([[LastSymbol, 1]|NonUniqueCountData], CountData),
  maplist([D,C]>>nth0(1, D, C), CountData, Counts), min_list(Counts, Min), max_list(Counts, Max).
count(pair{ps: [P, _], c: C}, [P,C]).
aggregate([], []).
aggregate([[HP,HC]|T], Aggregated) :- member(T, [HP, HC2], R), !, C is HC+HC2, aggregate([[HP,C]|R], Aggregated).
aggregate([H|T], [H|AggregatedT]) :- aggregate(T, AggregatedT).

transformTemplate([P], [], P).
transformTemplate([P1|[P2|PRest]], Pairs, PL) :- transformTemplate([P2|PRest], PairsRest, PL), (
  member(pair{ps: [P1, P2], c: C}, PairsRest, PairsRestWoP1) -> Cn is C + 1, Pairs = [pair{ps: [P1, P2], c: Cn}|PairsRestWoP1]
  ; Pairs = [pair{ps: [P1, P2], c: 1}|PairsRest]
).

applyRulesMultipleTimes(_, Pairs, 0, Pairs) :- !.
applyRulesMultipleTimes(Rules, Pairs, N, AppliedPairs) :- applyRules(Rules, Pairs, NextPairs), Nn is N - 1, applyRulesMultipleTimes(Rules, NextPairs, Nn, AppliedPairs).

applyRules(Rules, Pairs, AppliedPairs) :- applyRules(Rules, Pairs, RemainingPairs, NewPairs), mergePairs(RemainingPairs, NewPairs, AppliedPairs).

applyRules([], RemainingPairs, RemainingPairs, []).
applyRules([Rule|OtherRules], Pairs, RemainingPairs, AppliedPairs) :-
  applyRule(Rule, Pairs, RemainingPairAfterRule, PairsFromFirstRule),
  applyRules(OtherRules, RemainingPairAfterRule, RemainingPairs, PairsFromOtherRules),
  mergePairs(PairsFromFirstRule, PairsFromOtherRules, AppliedPairs).

applyRule(_, [], [], []) :- !.
applyRule(rule{pair: [P1, P2], insert: I}, [pair{ps: [P1, P2], c: C}|OtherPairs], RemainingPairs, AppliedPairs) :- !,
  applyRule(rule{pair: [P1, P2], insert: I}, OtherPairs, RemainingPairs, OtherAppliedPairs),
  mergePairs([pair{ps: [P1, I], c: C}, pair{ps: [I, P2], c: C}], OtherAppliedPairs, AppliedPairs).
applyRule(Rule, [FirstPair|OtherPairs], [FirstPair|RemainingPairs], AppliedPairs) :-
  applyRule(Rule, OtherPairs, RemainingPairs, AppliedPairs).

mergePairs([], Pairs2, Pairs2).
mergePairs([Pairs1H|Pairs1T], Pairs2, MergedPairs) :-
  member(Pairs2, pair{ps: Pairs1H.ps, c: C}, Pairs2Other), !,
  Sum is C + Pairs1H.c, mergePairs(Pairs1T, [pair{ps: Pairs1H.ps, c: Sum}|Pairs2Other], MergedPairs).
mergePairs([Pairs1H|Pairs1T], Pairs2, MergedPairs) :- mergePairs(Pairs1T, [Pairs1H|Pairs2], MergedPairs).

member([H|T], H, T).
member([H|T], M, [H|MT]) :- member(T, M, MT).

/* required for loadData */
data_line(Rule, Line) :- rule_line(Rule, Line).
data_line(Template, Line) :- string_chars(Line, Template), forall(member(P, Template), assertP(P)).

rule_line(rule{pair: [First, Second], insert: Insert}, Line) :- 
    split_string(Line, '>', ' -', [PairStr, InsertStr]), string_chars(PairStr, [First, Second]), string_chars(InsertStr, [Insert]),
    assertP(Insert), assert(rule(First, Second, Insert)).

assertP(P) :- (current_predicate(p/1), p(P)) -> true ; assert(p(P)).

resetData :- retractall(rule(_, _, _)), retractall(p(_)).