:- include('17.common.prolog'). testResult(45).

result([TargetArea], MaxHeight) :- MaxHeight is TargetArea.minY * (TargetArea.minY + 1) / 2.
