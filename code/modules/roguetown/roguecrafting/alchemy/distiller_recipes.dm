// Advanced alchemy - made only in a distiller, never a cauldron.
// Ingredients still advertise these via major_pot/med_pot/minor_pot, exactly like basic recipes.
// Every distiller recipe uses gold dust as its catalyst (inherited from the base type).

//Strong potions - distilled from their weaker form.
/datum/distiller_recipe/big_health_potion
	name = "Elixir of Health (Strong)"
	smells_like = "berry pie"
	skill_required = SKILL_LEVEL_EXPERT
	output_reagents = list(/datum/reagent/medicine/stronghealth = 90)
	base_reagent = /datum/reagent/medicine/healthpot

/datum/distiller_recipe/big_mana_potion
	name = "Elixir of Mana (Strong)"
	smells_like = "fear"
	skill_required = SKILL_LEVEL_EXPERT
	output_reagents = list(/datum/reagent/medicine/strongmana = 90)
	base_reagent = /datum/reagent/medicine/manapot

/datum/distiller_recipe/big_stamina_potion
	name = "Elixir of Stamina (Strong)"
	smells_like = "clean winds"
	skill_required = SKILL_LEVEL_EXPERT
	output_reagents = list(/datum/reagent/medicine/strongstam = 90)
	base_reagent = /datum/reagent/medicine/stampot

/datum/distiller_recipe/restoration_potion
	name = "Elixir of Restoration"
	smells_like = "fizzling berries"
	skill_required = SKILL_LEVEL_EXPERT
	output_reagents = list(/datum/reagent/medicine/restoration = 90)

//Expert poisons - distilled from their weaker form.
/datum/distiller_recipe/doompoison
	name = "Poison (Doom)"
	smells_like = "doom"
	skill_required = SKILL_LEVEL_EXPERT
	output_reagents = list(/datum/reagent/strongpoison = 90)
	base_reagent = /datum/reagent/berrypoison

/datum/distiller_recipe/big_stam_poison
	name = "Stamina Poison (Strong)"
	smells_like = "stagnant air"
	skill_required = SKILL_LEVEL_EXPERT
	output_reagents = list(/datum/reagent/strongstampoison = 90)
	base_reagent = /datum/reagent/stampoison

//Stat potions - distilled from plain water, gated by the catalyst and expert skill.
// Stat potions are weaker than strong potions, so they output half as much per score.
/datum/distiller_recipe/str_potion
	name = "Potion of Mountain Muscles"
	smells_like = "petrichor"
	skill_required = SKILL_LEVEL_EXPERT
	output_reagents = list(/datum/reagent/buff/strength = 30)
	potency_per_score = 7.5

/datum/distiller_recipe/per_potion
	name = "Potion of Keen Eye"
	smells_like = "fire"
	skill_required = SKILL_LEVEL_EXPERT
	output_reagents = list(/datum/reagent/buff/perception = 30)
	potency_per_score = 7.5

/datum/distiller_recipe/end_potion
	name = "Potion of Enduring Fortitude"
	smells_like = "mountain air"
	skill_required = SKILL_LEVEL_EXPERT
	output_reagents = list(/datum/reagent/buff/endurance = 30)
	potency_per_score = 7.5

/datum/distiller_recipe/con_potion
	name = "Potion of Stone Flesh"
	smells_like = "earth"
	skill_required = SKILL_LEVEL_EXPERT
	output_reagents = list(/datum/reagent/buff/constitution = 30)
	potency_per_score = 7.5

/datum/distiller_recipe/int_potion
	name = "Potion of Keen Mind"
	smells_like = "water"
	skill_required = SKILL_LEVEL_EXPERT
	output_reagents = list(/datum/reagent/buff/intelligence = 30)
	potency_per_score = 7.5

/datum/distiller_recipe/spd_potion
	name = "Potion of Fleet Foot"
	smells_like = "clean air"
	skill_required = SKILL_LEVEL_EXPERT
	output_reagents = list(/datum/reagent/buff/speed = 30)
	potency_per_score = 7.5

/datum/distiller_recipe/lck_potion
	name = "Potion of Seven Clovers"
	smells_like = "calming"
	skill_required = SKILL_LEVEL_EXPERT
	output_reagents = list(/datum/reagent/buff/fortune = 30)
	potency_per_score = 7.5
