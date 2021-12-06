printImage([]).
printImage([H|T]) :- printImageRow(H), write("\n"), printImage(T).
printImageRow([]).
printImageRow([H|T]) :- write(H), printImageRow(T).

left_right(LeftTileId, RightTileId) :-
  LeftTileId \== RightTileId,
  border(LeftTileId, _, 'right', LeftTileBorder),
  reverse(LeftTileBorder, RightTileBorder),  
  border(RightTileId, _, 'left', RightTileBorder).

border(TileRef, TileData, Edge, Border) :- refTile(TileRef, TileData), border(TileData, Edge, Border).
border([FirstRow|_], 'top', FirstRow).
border([LastRow|[]], 'bottom', Border) :- reverse(LastRow, Border).
border([_|OtherRows], 'bottom', Border) :- border(OtherRows, 'bottom', Border).
border(Tile, 'left', Border) :- maplist(head, Tile, FirstCol), reverse(FirstCol, Border).
border(Tile, 'right', Border) :- maplist(last, Tile, Border).

imageRow([Ref|[]], IgnoreTileIds) :- !, tileRef_id(Ref, Id), not(member(Id, IgnoreTileIds)).
imageRow([StartRef|[NextRef|OtherRefs]], IgnoreTileIds) :- tileRef_id(StartRef, StartId), not(member(StartId, IgnoreTileIds)),
  left_right(StartRef, NextRef),
  imageRow([NextRef|OtherRefs], [StartId|IgnoreTileIds]).

tileRef_id(ref{id:Id, o:Orientation, f:Flip}, Id) :- refTile(ref{id:Id, o:Orientation, f:Flip}, _).
tileRef_id_unchecked(ref{id:Id, o:_, f:_}, Id).

assembleImage([Row], UsedIds) :- Row = [ref{id:_, o:_, f:0}|_], imageRow(Row, []), maplist(tileRef_id_unchecked, Row, UsedIds).
assembleImage([FirstRow|OtherRows], UsedIds) :-
  OtherRows = [SecondRow|_],
  assembleImage(OtherRows, UsedBySubImage),
  imageRow(FirstRow, UsedBySubImage),
  top_bottom(FirstRow, SecondRow),
  maplist(tileRef_id_unchecked, FirstRow, UsedByRow),
  append(UsedBySubImage, UsedByRow, UsedIds).

borders([], _, []).
borders([FirstTileRef|OtherTileRefs], Edge, Border) :-
  border(FirstTileRef, _, Edge, FirstBorder),
  borders(OtherTileRefs, Edge, OthersBorder),
  append(FirstBorder, OthersBorder, Border).
  
top_bottom(TopRow, BottomRow) :- 
  borders(TopRow, 'bottom', Border), 
  reverse(BottomRow, ReverseBottomRow), 
  reverse(Border, ReverseBorder),
  borders(ReverseBottomRow, 'top', ReverseBorder).

rowSize(1, [_]) :- !.
rowSize(Size, [_|T]) :- Size > 1, plus(SizeT, 1, Size), rowSize(SizeT, T).
imageSize(1, Y, [Row]) :- !, rowSize(Y, Row).
imageSize(X, Y, [FirstRow|OtherRows]) :- X > 1, rowSize(Y, FirstRow), plus(XT, 1, X), imageSize(XT, Y, OtherRows).
imageSize(Size, Image) :- imageSize(Size, Size, Image).

rowPixels([[]|_], []).
rowPixels(Tiles, [FirstRowPixels|OtherRowPixels]) :-
  maplist(head, Tiles, TileFirstRows), flatten(TileFirstRows, FirstRowPixels),
  maplist(tail, Tiles, TileOtherRows), rowPixels(TileOtherRows, OtherRowPixels).

removeLast(List, ListWoLast) :- append(ListWoLast, [_], List).
removeFirst([_|T], T).
removeFirstAndLast(L, WoFirstAndLast) :- removeFirst(L, WoFirst), removeLast(WoFirst, WoFirstAndLast).
tilePixels(TileRef, Pixels) :-
  refTile(TileRef, [_|PixelsWithLRB]),
  removeLast(PixelsWithLRB, PixelsWithLR),
  maplist(removeFirstAndLast, PixelsWithLR, Pixels).

imagePixels([], []).
imagePixels([FirstRow|OtherRows], Pixels) :-
  maplist(tilePixels, FirstRow, FirstRowData),
  rowPixels(FirstRowData, FirstRowPixels),
  imagePixels(OtherRows, OtherRowsPixels),
  append(FirstRowPixels, OtherRowsPixels, Pixels).

pixelsMatch(_, []).
pixelsMatch([_|OtherPixels], [' '|OtherMonster]) :- !, pixelsMatch(OtherPixels, OtherMonster).
pixelsMatch(['#'|OtherPixels], ['#'|OtherMonster]) :- !, pixelsMatch(OtherPixels, OtherMonster).
monsterTopLeft(_, []).
monsterTopLeft([PixelsH|PixelsT], [MonsterH|MonsterT]) :- pixelsMatch(PixelsH, MonsterH), monsterTopLeft(PixelsT, MonsterT).

findMonsterInRow(Pixels, Monster) :- monsterTopLeft(Pixels, Monster).
findMonsterInRow(Pixels, Monster) :- maplist(tail, Pixels, TailPixels), findMonsterInRow(TailPixels, Monster).
findMonster([], _) :- !, fail.
findMonster(Pixels, Monster) :- findMonsterInRow(Pixels, Monster).
findMonster([_|Pixels], Monster) :- findMonster(Pixels, Monster).

findMonsterInFlip(_, Pixels, Monster) :- findMonster(Pixels, Monster).
findMonsterInFlip(C, Pixels, Monster) :- C > 0, flip(Pixels, FlippedPixels), plus(CNext, 1, C), findMonsterInFlip(CNext, FlippedPixels, Monster).
findMonsterInRotation(_, Pixels, Monster) :- findMonsterInFlip(1, Pixels, Monster).
findMonsterInRotation(C, Pixels, Monster) :- C > 0, rotate(Pixels, RotatedPixels), plus(CNext, 1, C), findMonsterInRotation(CNext, RotatedPixels, Monster).
findMonsterAnyOrientation(Pixels, Monster) :- findMonsterInRotation(3, Pixels, Monster).

monster(Monster) :- maplist(string_chars, ["                  # ", "#    ##    ##    ###", " #  #  #  #  #  #   "], Monster).

countInList([], _, 0).
countInList([Char|T], Char, Count) :- !, countInList(T, Char, NCount), plus(NCount, 1, Count).
countInList([_|T], Char, Count) :- countInList(T, Char, Count).
countInMatrix([], _, 0).
countInMatrix([H|T], Char, Count) :- countInList(H, Char, LCount), countInMatrix(T, Char, HCount), plus(LCount, HCount, Count).

solve(File) :-
  loadData(File),
  aggregate_all(count, ID, refTile(ref{id: ID, o: 0, f: 0}, _), TileCount),
  ImageSize is truncate(sqrt(TileCount)),
  imageSize(ImageSize, Image),
  assembleImage(Image, _),
  imagePixels(Image, Pixels), !,
  monster(Monster),
  aggregate_all(count, findMonsterAnyOrientation(Pixels, Monster), MonsterCount),
  countInMatrix(Monster, '#', MonsterPixelsC),
  countInMatrix(Pixels, '#', PixelsC),
  Result is PixelsC - MonsterCount * MonsterPixelsC,
  write(Result).
solveTest :- ['lib/loadData.prolog'], solveTestDay(20).
solveTest(N) :- ['lib/loadData.prolog'], solveTestDay(20, N).
solve :- ['lib/loadData.prolog'], solveDay(20).

loadData(File) :- reset, loadData(_, File), createAllOrientationsForCurTile.
reset :- retractall(curTileId(_)), retractall(tile(_, _)).

/* required for loadData */
data_line([], "") :- !.
data_line([], Line) :- parseTileId(Line), !.
data_line([], Line) :- parseTileLine(Line).

parseTileId(Line) :- 
  sub_string(Line, 0, _, _, "Tile "),
  sub_string(Line, 5, _, 1, IdString), number_string(Id, IdString),
  createAllOrientationsForCurTile,
  retractall(curTileId(_)),
  asserta(curTileId(Id)).

parseTileLine(Line) :-
  curTileId(Id), getOrCreateTile(Id, Data),
  string_chars(Line, LineData),
  retractall(tile(Id, _)),
  asserta(tile(Id, [LineData|Data])).

getOrCreateTile(Id, Data) :- tile(Id, Data), !.
getOrCreateTile(_, []).

createAllOrientationsForCurTile :-
  curTileId(Id), !, tile(Id, Data),
  createRotations(Id, Data, 3, 0),
  flip(Data, FlippedData),
  createRotations(Id, FlippedData, 3, 1).
createAllOrientationsForCurTile.

createRotations(Id, Data, 0, Flipped) :- !, assertz(refTile(ref{id: Id, o: 0, f: Flipped}, Data)).
createRotations(Id, Data, Rotation, Flipped) :- Rotation > 0, plus(NextRotation, 1, Rotation),
  assertz(refTile(ref{id: Id, o: Rotation, f: Flipped}, Data)), 
  rotate(Data, RotatedData),  
  createRotations(Id, RotatedData, NextRotation, Flipped).

rotate([[]|_], []) :- !.
rotate(Matrix, [ReverseHeads|TransposedTails]) :- !,
  maplist(head, Matrix, Heads), reverse(Heads, ReverseHeads),
  maplist(tail, Matrix, Tails),
  rotate(Tails, TransposedTails).

flip(Matrix, FlippedMatrix) :- maplist(reverse, Matrix, FlippedMatrix).

head([H|_], H).
tail([_|T], T).
last([L|[]], L) :- !.
last([_|T], L) :- last(T, L).