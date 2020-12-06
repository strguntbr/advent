everybodyAnswers(_, []).
everybodyAnswers(ANSWER, [GROUP_ANSWERS_H|GROUP_ANSWERS_T]) :- member(ANSWER, GROUP_ANSWERS_H), everybodyAnswers(ANSWER, GROUP_ANSWERS_T).
countGroupAnswers(GROUP_ANSWERS, COUNT) :- aggregate_all(count, everybodyAnswers(_, GROUP_ANSWERS), COUNT).

sumGroupAnswers([], 0).
sumGroupAnswers([H|T], SUM) :- countGroupAnswers(H, SUM_H), sumGroupAnswers(T, SUM_T), SUM is SUM_T + SUM_H.

solve(FILE) :- ['lib/loadData.prolog'], loadGroupedData(ANSWERS_PER_GROUP, FILE), sumGroupAnswers(ANSWERS_PER_GROUP, SUM), write(SUM).
solve :- solve('input/6.data').

/* required for loadData */
data_line(ANSWERS, LINE) :- string_chars(LINE, ANSWERS).