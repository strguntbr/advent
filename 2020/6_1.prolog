anybodyAnswers(ANSWER, [GROUP_ANSWERS_H|_]) :- member(ANSWER, GROUP_ANSWERS_H).
anybodyAnswers(ANSWER, [GROUP_ANSWERS_H|GROUP_ANSWERS_T]) :- anybodyAnswers(ANSWER, GROUP_ANSWERS_T), not(member(ANSWER, GROUP_ANSWERS_H)).
countGroupAnswers(GROUP_ANSWERS, COUNT) :- aggregate_all(count, anybodyAnswers(_, GROUP_ANSWERS), COUNT).

sumGroupAnswers([], 0).
sumGroupAnswers([H|T], SUM) :- countGroupAnswers(H, SUM_H), sumGroupAnswers(T, SUM_T), SUM is SUM_T + SUM_H.

solve(FILE) :- ['lib/loadData.prolog'], loadGroupedData(ANSWERS_PER_GROUP, FILE), sumGroupAnswers(ANSWERS_PER_GROUP, SUM), write(SUM).
solve :- solve('input/6.data').

/* required for loadData */
data_line(ANSWERS, LINE) :- string_chars(LINE, ANSWERS).