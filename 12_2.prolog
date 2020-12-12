pos_distance([X, Y], DISTANCE) :- dist(X, X_DIST), dist(Y, Y_DIST), DISTANCE is X_DIST+Y_DIST.
dist(RAW_DIST, RAW_DIST) :- RAW_DIST >= 0, !.
dist(RAW_DIST, DIST) :- RAW_DIST < 0, DIST is -RAW_DIST.

scale_vector([], _, []).
scale_vector([H|T], SCALE, [Hs|Ts]) :- Hs is H*SCALE, scale_vector(T, SCALE, Ts).
sum_vector([], [], []).
sum_vector([H1|T1], [H2|T2], [Hs|Ts]) :- Hs is H1+H2, sum_vector(T1, T2, Ts).
rot_vector([X, Y], 0, [X, Y]) :- !.
rot_vector([X, Y], 1, [Y, Xn]) :- !, Xn is -X.
rot_vector([X, Y], 2, [Xn, Yn]) :- !, Xn is -X, Yn is -Y.
rot_vector([X, Y], 3, [Yn, X]) :- !, Yn is -Y.
rot_vector(V, C, Vr) :- Cn is C mod 4, rot_vector(V, Cn, Vr).

move(V, mv{v: Vm}, NEXT_V) :- sum_vector(V, Vm, NEXT_V).
rotate(V, rot{count: C}, NEXT_V) :- rot_vector(V, C, NEXT_V).
sail(POS, V, D, NEXT_POS) :- scale_vector(V, D, Vs), sum_vector(POS, Vs, NEXT_POS).

execCmd(POS, V, CMD, POS, NEXT_V) :- move(V, CMD, NEXT_V).
execCmd(POS, V, CMD, POS, NEXT_V) :- rotate(V, CMD, NEXT_V).
execCmd(POS, V, sail{d: D}, NEXT_POS, V) :- sail(POS, V, D, NEXT_POS).

navigate(POS, _, [], POS).
navigate(START_POS, V, [FIRST_CMD|OTHER_CMDS], END_POS) :-
  execCmd(START_POS, V, FIRST_CMD, NEXT_POS, NEXT_V),
  navigate(NEXT_POS, NEXT_V, OTHER_CMDS, END_POS).

solve(FILE) :-
  ['lib/loadData.prolog'], 
  loadData(CMDS, FILE),
  navigate([0, 0], [10, -1], CMDS, TO),
  pos_distance(TO, DISTANCE),
  write(DISTANCE).
solve :- solve('input/12.data').

/* required for loadData */
data_line(CMD, LINE) :- string_chars(LINE, [OP|_]), sub_string(LINE, 1, _, 0, ARG), create_command(OP, ARG, CMD).
create_command('F', ARG, sail{d: D}) :- number_string(D, ARG).
create_command(MV_OP, ARG, mv{v: V}) :- mv_vector(MV_OP, Vb), number_string(S, ARG), scale_vector(Vb, S, V).
create_command('L', ARG, rot{count: COUNT}) :- rotCount(ARG, COUNT).
create_command('R', ARG, rot{count: COUNT}) :- rotCount(ARG, COUNTr), COUNT is -COUNTr.
rotCount("90", 1). rotCount("180", 2). rotCount("270", 3).
mv_vector('W', [-1, 0]). mv_vector('E', [1, 0]). mv_vector('N', [0, -1]). mv_vector('S', [0, 1]).