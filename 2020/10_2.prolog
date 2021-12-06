largerThan(X, Y) :- Y > X.

removeAdapter([H|T], MIN, MAX, H, T) :- H > MIN, H =< MAX.
removeAdapter([H|T], MIN, MAX, CUR_ADAPTER, [H|T_WO_CUR]) :- removeAdapter(T, MIN, MAX, CUR_ADAPTER, T_WO_CUR). 
connectAdapters(_, FROM, TO, []) :-  FROM >= TO - 3.
connectAdapters(ADAPTERS, FROM, TO, [CUR_ADAPTER|T]) :-
  MAX is FROM + 3,
  removeAdapter(ADAPTERS, FROM, MAX, CUR_ADAPTER, ADAPTERS_WO_CUR),
  connectAdapters(ADAPTERS_WO_CUR, CUR_ADAPTER, TO, T).

findWithDistance([_], _, []).
findWithDistance([H1|[H2|T]], DISTANCE, [H1|LIST]) :-
  DISTANCE =:= H2-H1, !,
  findWithDistance([H2|T], DISTANCE, LIST).
findWithDistance([_|T], DISTANCE, LIST) :- findWithDistance(T, DISTANCE, LIST).

partitionByDistance(ADAPTERS, DISTANCE, PARTITIONS) :-
  sort(ADAPTERS, SORTED_ADAPTERS),
  findWithDistance(SORTED_ADAPTERS, DISTANCE, PARTITION_BORDERS),
  partitionAdapters(SORTED_ADAPTERS, PARTITION_BORDERS, PARTITIONS).
partitionAdapters(ADAPTERS, [], [ADAPTERS]).
partitionAdapters(ADAPTERS, [FIRST_BORDER|OTHER_BORDERS], [FIRST_PARTITION|OTHER_PARTITIONS]) :-
  partition(largerThan(FIRST_BORDER), ADAPTERS, OTHER_ADAPTERS, FIRST_PARTITION),
  partitionAdapters(OTHER_ADAPTERS, OTHER_BORDERS, OTHER_PARTITIONS).
  
countPartitionSolutions(ADAPTERS, COUNT) :-
  min_list(ADAPTERS, MIN), max_list(ADAPTERS, MAX),
  START is MIN -3, END is MAX + 3,
  aggregate_all(count, connectAdapters(ADAPTERS, START, END, _), COUNT).

countAllSolutions([], 1).
countAllSolutions([FIRST_PARTITION|OTHER_PARTITIONS], COUNT) :-
  countPartitionSolutions(FIRST_PARTITION, FIRST_PARTITION_COUNT),
  countAllSolutions(OTHER_PARTITIONS, OTHER_PARTITIONS_COUNT),
  COUNT is FIRST_PARTITION_COUNT * OTHER_PARTITIONS_COUNT.

solve(FILE) :-
  ['lib/loadData.prolog'], 
  loadData(ADAPTERS, FILE),
  partitionByDistance([0|ADAPTERS], 3, PARTITIONS),
  countAllSolutions(PARTITIONS, COUNT),
  write(COUNT).
solve :- solve('input/10.data').

/* required for loadData */
data_line(ADAPTER, LINE) :- number_string(ADAPTER, LINE).