/**
 * A single alchemy recipe, makeable in one or more machines.
 *
 * `machines` is a bitfield (MACHINE_CAULDRON / MACHINE_DISTILLER) of where it can be brewed, so a
 * potion that exists in both tiers is one datum with both bits set - no duplicate recipes. Each
 * machine reads what it needs: the cauldron makes a flat batch from water, the distiller refines a
 * base liquid (+ catalyst) and scales the yield with ingredient score.
 */
/datum/alch_recipe
	abstract_type = /datum/alch_recipe
	var/name = ""
	var/category = "Potions"
	var/smells_like = "nothing" // The machine emits this smell when done; alchemists sniff ingredients to find what they do.
	var/skill_required = SKILL_LEVEL_APPRENTICE
	var/list/output_reagents = list() // reagent path => units. Remember, 1 oz is 3 units!
	var/list/output_items = list() // item path => count
	/// Ingredients that build toward this recipe: ingredient type => score weight (3/2/1).
	/// An ingredient may feed any number of recipes.
	var/list/ingredient_scores = list()
	/// Bitfield of machines that can make this recipe (MACHINE_CAULDRON, MACHINE_DISTILLER).
	var/machines = NONE
	// --- Distiller-only fields, ignored by the cauldron ---
	/// The liquid the distiller consumes as the base: water, or the weaker potion for the "strong" variants.
	var/base_reagent = /datum/reagent/water
	/// Units of base_reagent consumed for one standard brew.
	var/base_reagent_amount = 90
	/// The catalyst that must sit in the distiller - required to react, NEVER consumed.
	var/catalyst = /obj/item/alch/golddust
	/// Units of distiller output per point of ingredient score. Stat potions halve it to 7.5.
	var/potency_per_score = 15

/// Cauldron recipes: the basic tier, apprentice-gated by default.
/datum/alch_recipe/cauldron
	abstract_type = /datum/alch_recipe/cauldron
	machines = MACHINE_CAULDRON

/// Distiller recipes: the advanced tier, expert-gated, refined from a base liquid + catalyst.
/datum/alch_recipe/distiller
	abstract_type = /datum/alch_recipe/distiller
	machines = MACHINE_DISTILLER
	skill_required = SKILL_LEVEL_EXPERT

/datum/alch_recipe/proc/generate_html(mob/user)
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

	if(machines & MACHINE_CAULDRON)
		html += "Boil 90+ drams of water in a Cauldron.<br>"
	if(machines & MACHINE_DISTILLER)
		var/datum/reagent/base = base_reagent
		html += "Distill at least [base_reagent_amount] drams of [initial(base.name)] in a lit Distiller.<br>"
		if(catalyst)
			var/atom/cat = catalyst
			html += "Place [initial(cat.name)] inside as a catalyst - it is not consumed.<br>"

	html += "Add at least two ingredients with the smell of [smells_like]<br>"

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

/datum/alch_recipe/proc/show_menu(mob/user)
	user << browse(generate_html(user),"window=new_recipe;size=500x810")
