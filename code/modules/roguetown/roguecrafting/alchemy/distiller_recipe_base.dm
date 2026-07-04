// Shared alchemy scoring/indexing helpers. The recipe datum itself lives in alch_cauldron_recipe_base.dm.

/// Build [GLOB.alch_ingredient_recipes] by inverting every recipe's ingredient_scores into
/// ingredient type => list(recipe = weight). Run after GLOB.alch_recipes is populated.
/proc/build_alch_ingredient_index()
	var/list/index = list()
	for(var/datum/alch_recipe/rec as anything in GLOB.alch_recipes)
		for(var/ing_type in rec.ingredient_scores)
			var/list/entry = index[ing_type]
			if(!entry)
				entry = list()
				index[ing_type] = entry
			entry[rec] = rec.ingredient_scores[ing_type]
	// Sort each ingredient's recipes strongest-first so examine hints list in weight order.
	for(var/ing_type in index)
		index[ing_type] = sortTim(index[ing_type], cmp = /proc/cmp_numeric_dsc, associative = TRUE)
	GLOB.alch_ingredient_recipes = index

/// Score loaded ingredients against every recipe they feed. Returns recipe => total score,
/// sorted highest-first; duplicates stack. Callers take outcomes[1] and gate on score >= 5.
/proc/score_alch_ingredients(list/ingredients)
	var/list/outcomes = list()
	for(var/obj/item/alch/alching in ingredients)
		var/list/recipes = GLOB.alch_ingredient_recipes[alching.type]
		if(!recipes)
			continue
		for(var/datum/recipe as anything in recipes)
			if(outcomes[recipe])
				outcomes[recipe] += recipes[recipe]
			else
				outcomes[recipe] = recipes[recipe]
	sortTim(outcomes, cmp = /proc/cmp_numeric_dsc, associative = TRUE)
	return outcomes

/// From sorted scoring outcomes, return the highest-scoring recipe the given machine can make that
/// clears the >=5 threshold, or null. `machine` is a MACHINE_* flag; lets each machine pick its own
/// recipe when a potion exists in both tiers, instead of coin-flipping a tie on the top score.
/proc/best_alch_recipe(list/outcomes, machine)
	for(var/datum/alch_recipe/recipe as anything in outcomes) // outcomes is sorted highest-first
		if(outcomes[recipe] < 5)
			break
		if(recipe.machines & machine)
			return recipe
	return null
