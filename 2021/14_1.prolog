day(14). testResult(1588). groupData. solve :- ['lib/solve.prolog'], printResult.

result([[Template], _], Result) :-
  applyRules(Template, 10, AppliedTemplate),
  findall(P, p(P), Ps), maplist([P, C]>>count(AppliedTemplate, P, C), Ps, PCounts),
  max_list(PCounts, Max), min_list(PCounts, Min),
  Result is Max - Min.

applyRules(Template, 0, Template) :- !.
applyRules(Template, C, AppliedTemplate) :- applyRules(Template, NextTemplate), NextC is C -1, applyRules(NextTemplate, NextC, AppliedTemplate).
applyRules([], []).
applyRules([P1|[P2|PRest]], [P1|[Insert|AppliedTemplate]]) :- rule(P1, P2, Insert), !, applyRules([P2|PRest], AppliedTemplate).
applyRules([P1|PRest], [P1|AppliedTemplate]) :- applyRules(PRest, AppliedTemplate).

count([], _, 0).
count([H|T], P, C) :- count(T, P, Cn), ( H = P -> C is Cn + 1 ; C = Cn ).

/* required for loadData */
data_line(Rule, Line) :- rule_line(Rule, Line).
data_line(Template, Line) :- string_chars(Line, Template), forall(member(P, Template), assertP(P)).

rule_line(rule{pair: [First, Second], insert: Insert}, Line) :- 
    split_string(Line, '>', ' -', [PairStr, InsertStr]), string_chars(PairStr, [First, Second]), string_chars(InsertStr, [Insert]),
    assertP(Insert), assert(rule(First, Second, Insert)).

assertP(P) :- (current_predicate(p/1), p(P)) -> true ; assert(p(P)).

resetData :- retractall(rule(_, _, _)), retractall(p(_)).