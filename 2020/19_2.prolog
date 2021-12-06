validMessage(Message) :- message(Message), matchesRule(0, Message, []).

solve(File) :-
  loadData(_, File),
  aggregate_all(count, Message, validMessage(Message), ValidMessageCount),
  write(ValidMessageCount).
solveTest :- ['lib/loadData.prolog'], solveTestDay(19).
solveTest(N) :- ['lib/loadData.prolog'], solveTestDay(19, N).
solve :- ['lib/loadData.prolog'], solveDay(19).

/* required for loadData */
data_line([], Line) :- parseRule(Line), !.
data_line([], Line) :- parseMessage(Line).

parseMessage(Line) :-
  string_chars(Line, Message),
  assertz(message(Message)).

parseRule(Line) :- split_string(Line, ":", "", [RuleIdStr,Rule]), number_string(RuleId, RuleIdStr), defineRule(RuleId, Rule).

defineRule(8, _) :- !, defineSubRules(8, ["42", "42 8"]).
defineRule(11, _) :- !, defineSubRules(11, ["42 31", "42 11 31"]).

defineRule(RuleId, Rule) :- split_string(Rule, "|", "", SubRules), defineSubRules(RuleId, SubRules).
defineSubRules(_, []).
defineSubRules(RuleId, [FirstSubRule|OtherSubRules]) :- defineSubRule(RuleId, FirstSubRule), defineSubRules(RuleId, OtherSubRules).
defineSubRule(RuleId, SubRule) :-
  string_chars(SubRule, [' ', '"', Char, '"']), !, 
  assertz(matchesRule(RuleId, [Char|After], After)).
defineSubRule(RuleId, SubRule) :-
  split_string(SubRule, " ", " ", SubRuleIdStrs), !, numbers_strings(SubRuleIds, SubRuleIdStrs),
  assertz(matchesRule(RuleId, Input, Output) :- matchesSubRules(SubRuleIds, Input, Output)).

numbers_strings([] ,[]).
numbers_strings([Nh|Nt], [Sh|St]) :- number_string(Nh, Sh), numbers_strings(Nt, St).

matchesSubRules([], Input, Input).
matchesSubRules([FirstSubRule|OtherSubRules], Input, Output) :- matchesRule(FirstSubRule, Input, OtherInput), matchesSubRules(OtherSubRules, OtherInput, Output).