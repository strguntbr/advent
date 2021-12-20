:- include('20.common.prolog'). testResult(3351).

result([[Algorithm], Image], LitPixels) :-
  enhanceImage(Image, Algorithm, 50, '.', EnhancedImage),
  countLitPixels(EnhancedImage, LitPixels).
