day(21).

eachFoodContainsIngredient(_, []).
eachFoodContainsIngredient(Ingredient, [FirstFood|OtherFoods]) :-
  member(Ingredient, FirstFood),
  eachFoodContainsIngredient(Ingredient, OtherFoods).

allFoodsWithAllergen(Allergen, Foods) :- findall(Food, foodContainsAllergen(Food, Allergen), Foods).

allergen_possibleIngredient(Allergen, Ingredient) :-
  allFoodsWithAllergen(Allergen, Foods),
  eachFoodContainsIngredient(Ingredient, Foods),
  findall(KnownIngredient, allergen_ingredient(_, KnownIngredient), KnownIngredients),
  not(member(Ingredient, KnownIngredients)).

unresolvedAllergen(Allergen) :- allergen(Allergen), not(allergen_ingredient(Allergen, _)).

resolveAllergens :- aggregate_all(count, unresolvedAllergen(_), 0), !.
resolveAllergens :-
  allergen(Allergen), not(allergen_ingredient(Allergen, _)),
  aggregate_all(bag(PossibleIngredient), PossibleIngredient, allergen_possibleIngredient(Allergen, PossibleIngredient), [Ingredient]),
  assertz(allergen_ingredient(Allergen, Ingredient)),
  !, resolveAllergens.

isAllergenic(IngredientWithAllergen) :- allergen_ingredient(_, IngredientWithAllergen).
ingredientsWithoutAllergens(Food, IngredientsWithoutAllergens) :- exclude(isAllergenic, Food, IngredientsWithoutAllergens).

solve(File) :-
  loadData(File),
  resolveAllergens,
  findall(Food, food(Food), Foods),
  maplist(ingredientsWithoutAllergens, Foods, IngredientsWithoutAllergens),
  maplist(length, IngredientsWithoutAllergens, Lengths),
  aggregate(sum(L), member(L, Lengths), IngredientsWithoutAllergensCount),
  !, write(IngredientsWithoutAllergensCount).
solveTest :- ['lib/loadData.prolog'], day(DAY), solveTestDay(DAY).
solveTest(N) :- ['lib/loadData.prolog'], day(DAY), solveTestDay(DAY, N).
solve :- ['lib/loadData.prolog'], day(DAY), solveDay(DAY).

loadData(File) :- reset, loadData(_, File).
reset :- retractall(food(_)), retractall(allergen(_)), retractall(ingredient(_)), retractall(foodContainsAllergen(_, _)), retractall(allergen_ingredient(_, _)).

/* required for loadData */
data_line([], Line) :-
  sub_string(Line, FoodLength, _, AllergenLengthT, " (contains "), AllergenLength is AllergenLengthT-1,
  sub_string(Line, 0, FoodLength, _, Food),
  sub_string(Line, _, AllergenLength, 1, AllergenStr),
  split_string(Food, " ", "", Ingredients),
  split_string(AllergenStr, ",", " ", Allergens),
  createFood(Ingredients),
  createAllergens(Allergens, Ingredients).

createAllergens([], _).
createAllergens([FirstAllergen|OtherAllergens], Ingredients) :-
  createAllergen(FirstAllergen),
  createFoodWithAllergen(Ingredients, FirstAllergen),
  createAllergens(OtherAllergens, Ingredients).

createFood(Food) :- food(Food), !.
createFood(Food) :- assertz(food(Food)).

createFoodWithAllergen(Food, Allergen) :- foodContainsAllergen(Food, Allergen), !.
createFoodWithAllergen(Food, Allergen) :- assertz(foodContainsAllergen(Food, Allergen)).

createAllergen(Allergen) :- allergen(Allergen), !.
createAllergen(Allergen) :- assertz(allergen(Allergen)).

createIngredients([]).
createIngredients([FirstIngredient|OtherIngredients]) :-
  createIngredient(FirstIngredient),
  createIngredients(OtherIngredients).

createIngredient(Ingredient) :- ingredient(Ingredient), !.
createIngredient(Ingredient) :- assertz(ingredient(Ingredient)).