:- include('20.common.prolog'). testResult(35).

result([[Algorithm], Image], LitPixels) :-
  enhanceImage(Image, Algorithm, 2, '.', EnhancedImage),
  countLitPixels(EnhancedImage, LitPixels).
