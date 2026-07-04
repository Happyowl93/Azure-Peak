// Advanced alchemy - made only in a distiller, never a cauldron.
// Each recipe lists the ingredients that build toward it in `ingredient_scores` (type => 3/2/1), exactly like basic recipes.
// Every distiller recipe uses gold dust as its catalyst (inherited from the base type).

//Strong potions - distilled from their weaker form.
/datum/distiller_recipe/big_health_potion
	name = "Elixir of Health (Strong)"
	smells_like = "berry pie"
	skill_required = SKILL_LEVEL_EXPERT
	output_reagents = list(/datum/reagent/medicine/stronghealth = 90)
	base_reagent = /datum/reagent/medicine/healthpot
	ingredient_scores = list(
		/obj/item/alch/calendula = 3,
		/obj/item/alch/viscera = 3,
		/obj/item/alch/silverdust = 1,
	)

/datum/distiller_recipe/big_mana_potion
	name = "Elixir of Mana (Strong)"
	smells_like = "fear"
	skill_required = SKILL_LEVEL_EXPERT
	output_reagents = list(/datum/reagent/medicine/strongmana = 90)
	base_reagent = /datum/reagent/medicine/manapot
	ingredient_scores = list(
		/obj/item/alch/golddust = 3,
		/obj/item/alch/magicdust = 3,
		/obj/item/alch/feaudust = 2,
		/obj/item/alch/hypericum = 2,
		/obj/item/alch/mineraldust = 2,
		/obj/item/alch/runedust = 2,
		/obj/item/alch/waterdust = 2,
		/obj/item/alch/berrypowder = 1,
		/obj/item/alch/manabloompowder = 1,
		/obj/item/alch/puresalt = 1,
	)

/datum/distiller_recipe/big_stamina_potion
	name = "Elixir of Stamina (Strong)"
	smells_like = "clean winds"
	skill_required = SKILL_LEVEL_EXPERT
	output_reagents = list(/datum/reagent/medicine/strongstam = 90)
	base_reagent = /datum/reagent/medicine/stampot
	ingredient_scores = list(
		/obj/item/alch/benedictus = 3,
		/obj/item/alch/ozium = 3,
		/obj/item/alch/seeddust = 3,
	)

/datum/distiller_recipe/restoration_potion
	name = "Elixir of Restoration"
	smells_like = "fizzling berries"
	skill_required = SKILL_LEVEL_EXPERT
	output_reagents = list(/datum/reagent/medicine/restoration = 90)
	ingredient_scores = list(
		/obj/item/alch/golddust = 2,
		/obj/item/alch/silverdust = 2,
		/obj/item/alch/rosa = 1,
		/obj/item/alch/rosa/azure = 1,
	)

//Expert poisons - distilled from their weaker form.
/datum/distiller_recipe/doompoison
	name = "Poison (Doom)"
	smells_like = "doom"
	skill_required = SKILL_LEVEL_EXPERT
	output_reagents = list(/datum/reagent/strongpoison = 90)
	base_reagent = /datum/reagent/berrypoison
	ingredient_scores = list(
		/obj/item/alch/atropa = 3,
		/obj/item/alch/mineraldust = 3,
		/obj/item/alch/matricaria = 1,
	)

/datum/distiller_recipe/big_stam_poison
	name = "Stamina Poison (Strong)"
	smells_like = "stagnant air"
	skill_required = SKILL_LEVEL_EXPERT
	output_reagents = list(/datum/reagent/strongstampoison = 90)
	base_reagent = /datum/reagent/stampoison
	ingredient_scores = list(
		/obj/item/alch/paris = 3,
		/obj/item/alch/infernaldust = 2,
		/obj/item/alch/swampdust = 2,
		/obj/item/alch/mineraldust = 1,
	)

//Stat potions - distilled from plain water, gated by the catalyst and expert skill.
// Stat potions are weaker than strong potions, so they output half as much per score.
/datum/distiller_recipe/str_potion
	name = "Potion of Mountain Muscles"
	smells_like = "petrichor"
	skill_required = SKILL_LEVEL_EXPERT
	output_reagents = list(/datum/reagent/buff/strength = 30)
	potency_per_score = 7.5
	ingredient_scores = list(
		/obj/item/alch/firedust = 3,
		/obj/item/alch/horn = 3,
		/obj/item/alch/salvia = 2,
		/obj/item/alch/coaldust = 1,
		/obj/item/alch/earthdust = 1,
		/obj/item/alch/irondust = 1,
	)

/datum/distiller_recipe/per_potion
	name = "Potion of Keen Eye"
	smells_like = "fire"
	skill_required = SKILL_LEVEL_EXPERT
	output_reagents = list(/datum/reagent/buff/perception = 30)
	potency_per_score = 7.5
	ingredient_scores = list(
		/obj/item/alch/mentha = 3,
		/obj/item/alch/tobaccodust = 3,
		/obj/item/alch/bonemeal = 2,
		/obj/item/alch/matricaria = 2,
		/obj/item/alch/golddust = 1,
		/obj/item/alch/runedust = 1,
		/obj/item/alch/solardust = 1,
		/obj/item/alch/waterdust = 1,
	)

/datum/distiller_recipe/end_potion
	name = "Potion of Enduring Fortitude"
	smells_like = "mountain air"
	skill_required = SKILL_LEVEL_EXPERT
	output_reagents = list(/datum/reagent/buff/endurance = 30)
	potency_per_score = 7.5
	ingredient_scores = list(
		/obj/item/alch/irondust = 3,
		/obj/item/alch/calendula = 2,
		/obj/item/alch/coaldust = 2,
		/obj/item/alch/earthdust = 2,
		/obj/item/alch/magicdust = 2,
		/obj/item/alch/sinew = 2,
		/obj/item/alch/horn = 1,
		/obj/item/alch/salvia = 1,
		/obj/item/alch/swampdust = 1,
	)

/datum/distiller_recipe/con_potion
	name = "Potion of Stone Flesh"
	smells_like = "earth"
	skill_required = SKILL_LEVEL_EXPERT
	output_reagents = list(/datum/reagent/buff/constitution = 30)
	potency_per_score = 7.5
	ingredient_scores = list(
		/obj/item/alch/earthdust = 3,
		/obj/item/alch/salvia = 3,
		/obj/item/alch/firedust = 2,
		/obj/item/alch/horn = 2,
		/obj/item/alch/irondust = 2,
		/obj/item/alch/bone = 1,
		/obj/item/alch/magicdust = 1,
	)

/datum/distiller_recipe/int_potion
	name = "Potion of Keen Mind"
	smells_like = "water"
	skill_required = SKILL_LEVEL_EXPERT
	output_reagents = list(/datum/reagent/buff/intelligence = 30)
	potency_per_score = 7.5
	ingredient_scores = list(
		/obj/item/alch/runedust = 3,
		/obj/item/alch/waterdust = 3,
		/obj/item/alch/manabloompowder = 2,
		/obj/item/alch/mentha = 2,
		/obj/item/alch/solardust = 2,
		/obj/item/alch/airdust = 1,
		/obj/item/alch/benedictus = 1,
		/obj/item/alch/euphrasia = 1,
		/obj/item/alch/infernaldust = 1,
		/obj/item/alch/ozium = 1,
	)

/datum/distiller_recipe/spd_potion
	name = "Potion of Fleet Foot"
	smells_like = "clean air"
	skill_required = SKILL_LEVEL_EXPERT
	output_reagents = list(/datum/reagent/buff/speed = 30)
	potency_per_score = 7.5
	ingredient_scores = list(
		/obj/item/alch/airdust = 3,
		/obj/item/alch/euphrasia = 3,
		/obj/item/alch/feaudust = 3,
		/obj/item/alch/artemisia = 2,
		/obj/item/alch/urtica = 2,
		/obj/item/alch/valeriana = 2,
		/obj/item/alch/tobaccodust = 1,
	)

/datum/distiller_recipe/lck_potion
	name = "Potion of Seven Clovers"
	smells_like = "calming"
	skill_required = SKILL_LEVEL_EXPERT
	output_reagents = list(/datum/reagent/buff/fortune = 30)
	potency_per_score = 7.5
	ingredient_scores = list(
		/obj/item/alch/artemisia = 3,
		/obj/item/alch/rosa = 3,
		/obj/item/alch/rosa/azure = 3,
		/obj/item/alch/ozium = 2,
		/obj/item/alch/sleep_powder = 2,
		/obj/item/alch/briar_essence = 1,
	)
