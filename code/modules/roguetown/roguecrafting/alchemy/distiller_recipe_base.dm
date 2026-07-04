/**
 * A distiller recipe - the advanced tier of alchemy.
 *
 * Self-contained and wholly separate from /datum/alch_cauldron_recipe: a plain cauldron
 * can never make one. To run it in a distiller you need, all at once, the [base_reagent]
 * poured in (water for stat potions, or the weaker potion for the "strong" variants), the
 * usual smell-matched ingredients, and the [catalyst] - a pinch of gold dust - which is
 * required to react but is NEVER consumed.
 */
/datum/distiller_recipe
	abstract_type = /datum/distiller_recipe // Abstract, never instantiated directly.
	var/name = ""
	var/category = "Potions"
	var/smells_like = "nothing" //Distiller emits this smell when done; alchemists sniff ingredients to find what they do.
	var/skill_required = SKILL_LEVEL_EXPERT //Advanced potions default to Expert-gated.
	var/list/output_reagents = list() //list of paths of new reagents to create. Remember, 1 oz is 3 units! [reagent = amnt]
	var/list/output_items = list() //List of paths for new items that should be created.
	/// The liquid the distiller consumes as the base: water for stat potions, or the weaker potion for the "strong" variants.
	var/base_reagent = /datum/reagent/water
	/// Units of [base_reagent] consumed - one full brew, matching the cauldron.
	var/base_reagent_amount = 90
	/// The catalyst that must sit in the distiller - gold dust by default. Required to react, NEVER consumed.
	var/catalyst = /obj/item/alch/golddust
	/// Units of output per point of ingredient score. Max score is 18 (6 ingredients × 3),
	/// so strong potions use 15 (18 × 15 = 270u). Stat potions override to 7.5 (half).
	var/potency_per_score = 15
	/// Ingredients that build toward this recipe: ingredient type => score weight (3/2/1).
	/// An ingredient may feed any number of recipes.
	var/list/ingredient_scores = list()

/datum/distiller_recipe/proc/generate_html(mob/user)
	var/client/client = user
	if(!istype(client))
		client = user.client
	user << browse_rsc('html/book.png')
	var/html = {"
		<!DOCTYPE html>
		<html lang="en">
		<meta charset='UTF-8'>
		<meta http-equiv='X-UA-Compatible' content='IE=edge,chrome=1'/>
		<meta http-equiv='Content-Type' content='text/html; charset=UTF-8'/>
		<body>
		  <div>
		    <h1>[name]</h1>
		"}

	html += "Requires [SSskills.level_names_plain[skill_required]] level of skills<br>"

	var/datum/reagent/base = base_reagent
	html += "Distill at least [base_reagent_amount] drams of [initial(base.name)] in a lit Distiller.<br>"

	html += "Add at least two ingredients with the smell of [smells_like]<br>"

	if(catalyst)
		var/atom/cat = catalyst
		html += "Place [initial(cat.name)] inside as a catalyst - it is not consumed.<br>"

	if(output_reagents.len)
		html += "<div><strong>Creates:</strong><br>"
		for(var/path as anything in output_reagents)
			var/count = output_reagents[path]
			if(ispath(path, /datum/reagent))
				var/datum/reagent/R = path
				html += "[FLOOR(count, 1)] [UNIT_FORM_STRING(FLOOR(count, 1))] of [initial(R.name)]<br>"
		html += "</div>"

	if(output_items.len)
		html += "<div><strong>Guaranteed Outputs</strong><br>"
		for(var/path as anything in output_items)
			var/count = output_items[path]
			if(ispath(path, /obj))
				var/atom/atom = path
				html += "- [count] [initial(atom.name)]<br>"
		html += "</div>"

	html += {"
		</div>
		</div>
	</body>
	</html>
	"}
	return html

/datum/distiller_recipe/proc/show_menu(mob/user)
	user << browse(generate_html(user),"window=new_distiller_recipe;size=500x810")

/// Look up an alchemy recipe (cauldron or distiller) by typepath and return its examine hint, or null.
/// Ingredients advertise recipe typepaths of either kind, so this searches both registries.
/proc/alchemy_recipe_hint(recipe_path)
	var/datum/alch_cauldron_recipe/crec = locate(recipe_path) in GLOB.alch_cauldron_recipes
	if(crec)
		return list("smell" = crec.smells_like, "name" = crec.name)
	var/datum/distiller_recipe/drec = locate(recipe_path) in GLOB.distiller_recipes
	if(drec)
		return list("smell" = drec.smells_like, "name" = drec.name)
	return null

/// Build [GLOB.alch_ingredient_recipes] by inverting every recipe's ingredient_scores into
/// ingredient type => list(recipe = weight). Run after both recipe registries are populated.
/proc/build_alch_ingredient_index()
	var/list/index = list()
	for(var/datum/alch_cauldron_recipe/crec as anything in GLOB.alch_cauldron_recipes)
		for(var/ing_type in crec.ingredient_scores)
			var/list/entry = index[ing_type]
			if(!entry)
				entry = list()
				index[ing_type] = entry
			entry[crec] = crec.ingredient_scores[ing_type]
	for(var/datum/distiller_recipe/drec as anything in GLOB.distiller_recipes)
		for(var/ing_type in drec.ingredient_scores)
			var/list/entry = index[ing_type]
			if(!entry)
				entry = list()
				index[ing_type] = entry
			entry[drec] = drec.ingredient_scores[ing_type]
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
