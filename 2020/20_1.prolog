listProduct([], 1).
listProduct([H|T], P) :- listProduct(T, Pt), P is H*Pt.

cornerTile(TileId) :- tile(TileId, _), countBorderForTile(TileId, 2).
edgeTile(TileId) :- tile(TileId, _), countBorderForTile(TileId, 3).
innerTile(TileId) :- tile(TileId, _), countBorderForTile(TileId, 4).

countBorderForTile(TileId, BorderCount) :- tile(TileId, _), aggregate_all(count, OtherTileId, matchingBorders(TileId, OtherTileId), BorderCount).

matchingBorders(Tile1Id, Tile2Id) :-
  tile(Tile1Id, _), tile(Tile2Id, _), Tile1Id \== Tile2Id,
  border(Tile1Id, Border), border(Tile2Id, Border).

border(TileId, Border) :- tile(TileId, Tile), borderOfTile(Tile, Border).

borderOfTile(Tile, Border) :- borderTop(Tile, Border).
borderOfTile(Tile, Border) :- borderBottom(Tile, Border).
borderOfTile(Tile, Border) :- borderLeft(Tile, Border).
borderOfTile(Tile, Border) :- borderRight(Tile, Border).
borderOfTile(Tile, Border) :- borderTop(Tile, Row), reverse(Row, Border).
borderOfTile(Tile, Border) :- borderBottom(Tile, Row), reverse(Row, Border).
borderOfTile(Tile, Border) :- borderLeft(Tile, Row), reverse(Row, Border).
borderOfTile(Tile, Border) :- borderRight(Tile, Row), reverse(Row, Border).

borderTop([FirstRow|_], FirstRow).

borderBottom([LastRow|[]], Border) :- !, reverse(LastRow, Border).
borderBottom([_|OtherRows], Border) :- borderBottom(OtherRows, Border).

firstCol([], []).
firstCol([[FirstPixel|_]|OtherRows], [FirstPixel|OtherPixels]) :- firstCol(OtherRows, OtherPixels).
borderLeft(Tile, Border) :- firstCol(Tile, FirstCol), reverse(FirstCol, Border).

lastPixel([Pixel|[]], Pixel) :- !.
lastPixel([_|OtherPixels], LastPixel) :- lastPixel(OtherPixels, LastPixel).
lastCol([], []).
lastCol([FirstRow|OtherRows], [FirstPixel|OtherPixels]) :- lastPixel(FirstRow, FirstPixel), lastCol(OtherRows, OtherPixels).
borderRight(Tile, Border) :- lastCol(Tile, Border).

solve(File) :-
  loadData(File),
  findall(TileId, cornerTile(TileId), CornerTiles),
  listProduct(CornerTiles, Product),  
  write(Product).
solveTest :- ['lib/loadData.prolog'], solveTestDay(20).
solveTest(N) :- ['lib/loadData.prolog'], solveTestDay(20, N).
solve :- ['lib/loadData.prolog'], solveDay(20).

loadData(File) :- reset, loadData(_, File).
reset :- retractall(curTileId(_)), retractall(tile(_, _)).

/* required for loadData */
data_line([], "") :- !.
data_line([], Line) :- parseTileId(Line), !.
data_line([], Line) :- parseTileLine(Line).

parseTileId(Line) :- 
  sub_string(Line, 0, _, _, "Tile "),
  sub_string(Line, 5, _, 1, IdString), number_string(Id, IdString),
  retractall(curTileId(_)),
  asserta(curTileId(Id)).

parseTileLine(Line) :-
  curTileId(Id), getOrCreateTile(Id, Data),
  string_chars(Line, LineData),
  retractall(tile(Id, _)),
  asserta(tile(Id, [LineData|Data])).

getOrCreateTile(Id, Data) :- tile(Id, Data), !.
getOrCreateTile(_, []).