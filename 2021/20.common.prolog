:- include('lib/solve.prolog'). day(20). groupData.

:- include('lib/binary.prolog').

enhanceImage(Image, _, 0, _, Image).
enhanceImage(Image, Algorithm, C, OutsidePixel, EnhancedImage) :-
  padImage(Image, OutsidePixel, PaddedImage),
  doEnhanceImage(PaddedImage, Algorithm, OutsidePixel, NextImage),
  CN is C-1,
  lookup([OutsidePixel,OutsidePixel,OutsidePixel,OutsidePixel,OutsidePixel,OutsidePixel,OutsidePixel,OutsidePixel,OutsidePixel], Algorithm, NextOutsidePixel),
  enhanceImage(NextImage, Algorithm, CN, NextOutsidePixel, EnhancedImage).

countLitPixels([], 0).
countLitPixels([H|T], LitPixels) :-
  aggregate_all(count, member('#', H), HLitPixels),
  countLitPixels(T, TLitPixels),
  LitPixels is HLitPixels + TLitPixels.

doEnhanceImage(Image, Algorithm, OutsidePixel, EnhancedImage) :-
  Image=[L0,L1,L2|LR], !,
  doEnhanceLine([L0,L1,L2], Algorithm, OutsidePixel, E),
  doEnhanceImage([L1,L2|LR], Algorithm, OutsidePixel, ER),
  EnhancedImage=[E|ER].
doEnhanceImage(_, _, _, []).

doEnhanceLine([P,C,N], Algorithm, OutsidePixel, EnhancedLine) :-
  P=[P0,P1,P2|PR], C=[C0,C1,C2|CR], N=[N0,N1,N2|NR], !,
  lookup([P0,P1,P2,C0,C1,C2,N0,N1,N2], Algorithm, E),
  doEnhanceLine([[P1,P2|PR], [C1,C2|CR], [N1,N2|NR]], Algorithm, OutsidePixel, ER),
  EnhancedLine=[E|ER].
doEnhanceLine(_, _, _, []).

ensureLength(List, Length, _, List) :- length(List, L), L >= Length, !.
ensureLength(List, Length, Padding, FilledList) :- append(List, [Padding], NextList), ensureLength(NextList, Length, Padding, FilledList).

lookup(Pixels, Algorithm, EnhancedPixel) :-
  maplist(pixel_bit, Pixels, Bits), binary_value(Bits, Index),
  nth0(Index, Algorithm, EnhancedPixel).

pixel_bit('.', 0).
pixel_bit('#', 1).

padImage(Image, OutsidePixel, PaddedImage) :-
  padLines(Image, OutsidePixel, PaddedLines),
  PaddedLines=[H|_], length(H, L), ensureLength([], L, OutsidePixel, PaddedLine),
  append([PaddedLine,PaddedLine|PaddedLines], [PaddedLine,PaddedLine], PaddedImage).
  
padLines([], _, []).
padLines([H|T], OutsidePixel, [PaddedH|PaddedT]) :- padLine(H, OutsidePixel, PaddedH), padLines(T, OutsidePixel, PaddedT).

padLine(Line, OutsidePixel, PaddedLine) :- append([OutsidePixel,OutsidePixel|Line], [OutsidePixel,OutsidePixel], PaddedLine).

/* required for loadData */
data_line(Pixels, Line) :- string_chars(Line, Pixels).
