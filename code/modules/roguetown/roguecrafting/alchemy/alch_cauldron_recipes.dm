// Basic alchemy - brewed in a cauldron.
// The advanced tier (strong potions, stat potions, and the two expert poisons) lives in
// distiller_recipes.dm as /datum/distiller_recipe and can only be made in a distiller.

/datum/alch_cauldron_recipe/antidote
	name = "Antidote"
	smells_like = "wet moss"
	output_reagents = list(/datum/reagent/medicine/antidote = 90)
	ingredient_scores = list(
		/obj/item/alch/coaldust = 3,
		/obj/item/alch/puresalt = 3,
		/obj/item/alch/briar_essence = 2,
		/obj/item/alch/rosa = 2,
		/obj/item/alch/rosa/azure = 2,
		/obj/item/alch/bonemeal = 1,
		/obj/item/alch/hypericum = 1,
		/obj/item/alch/symphitum = 1,
		/obj/item/alch/taraxacum = 1,
		/obj/item/alch/viscera = 1,
	)

/datum/alch_cauldron_recipe/strong_antidote
	name = "Antidote (Strong)"
	smells_like = "purity"
	output_reagents = list(/datum/reagent/medicine/strong_antidote = 90)
	ingredient_scores = list(
		/obj/item/alch/bone = 3,
		/obj/item/alch/silverdust = 3,
		/obj/item/alch/puresalt = 2,
		/obj/item/alch/feaudust = 1,
		/obj/item/alch/seeddust = 1,
	)

/datum/alch_cauldron_recipe/berrypoison
	name = "Poison (Berry)"
	smells_like = "death"
	skill_required = SKILL_LEVEL_JOURNEYMAN // Basic poison should be harder to handle
	output_reagents = list(/datum/reagent/berrypoison = 90)
	ingredient_scores = list(
		/obj/item/alch/berrypowder = 3,
		/obj/item/alch/matricaria = 3,
		/obj/item/alch/swampdust = 3,
		/obj/item/alch/atropa = 2,
		/obj/item/alch/paris = 2,
	)

/datum/alch_cauldron_recipe/stam_poison
	name = "Stamina Poison"
	smells_like = "a slow breeze"
	skill_required = SKILL_LEVEL_JOURNEYMAN // Basic poison should be harder to handle
	output_reagents = list(/datum/reagent/stampoison = 90)
	ingredient_scores = list(
		/obj/item/alch/sinew = 3,
		/obj/item/alch/taraxacum = 3,
		/obj/item/alch/euphrasia = 2,
		/obj/item/alch/symphitum = 2,
		/obj/item/alch/atropa = 1,
		/obj/item/alch/paris = 1,
		/obj/item/alch/valeriana = 1,
	)

/datum/alch_cauldron_recipe/sleeping_poison
	name = "Sleep Poison"
	smells_like = "numbing mint"
	skill_required = SKILL_LEVEL_MASTER // Fairly potent, let's lock it behind high alchemy skill.
	output_reagents = list(/datum/reagent/sleep_powder = 90)
	ingredient_scores = list(
		/obj/item/alch/briar_essence = 3,
		/obj/item/alch/sleep_powder = 3,
	)

//Healing potions
/datum/alch_cauldron_recipe/health_potion
	name = "Elixir of Health"
	smells_like = "sweet berries"
	output_reagents = list(/datum/reagent/medicine/healthpot = 90)
	ingredient_scores = list(
		/obj/item/alch/symphitum = 3,
		/obj/item/alch/urtica = 3,
		/obj/item/alch/valeriana = 3,
		/obj/item/alch/bone = 2,
		/obj/item/alch/taraxacum = 2,
		/obj/item/alch/viscera = 2,
		/obj/item/alch/artemisia = 1,
		/obj/item/alch/calendula = 1,
		/obj/item/alch/sinew = 1,
	)

/datum/alch_cauldron_recipe/mana_potion
	name = "Elixir of Mana"
	smells_like = "power"
	output_reagents = list(/datum/reagent/medicine/manapot = 90)
	ingredient_scores = list(
		/obj/item/alch/bonemeal = 3,
		/obj/item/alch/manabloompowder = 3,
		/obj/item/alch/berrypowder = 2,
		/obj/item/alch/sleep_powder = 1,
	)

/datum/alch_cauldron_recipe/stamina_potion
	name = "Elixir of Stamina"
	smells_like = "fresh air"
	output_reagents = list(/datum/reagent/medicine/stampot = 90)
	ingredient_scores = list(
		/obj/item/alch/hypericum = 3,
		/obj/item/alch/airdust = 2,
		/obj/item/alch/benedictus = 2,
		/obj/item/alch/seeddust = 2,
		/obj/item/alch/tobaccodust = 2,
		/obj/item/alch/mentha = 1,
		/obj/item/alch/urtica = 1,
	)

/datum/alch_cauldron_recipe/fire_potion
	name = "Potion of Fire Warding"
	smells_like = "authority"
	skill_required = SKILL_LEVEL_MASTER
	output_reagents =list(/datum/reagent/fire_resist = 30)
	ingredient_scores = list(
		/obj/item/alch/infernaldust = 3,
		/obj/item/alch/solardust = 3,
		/obj/item/alch/firedust = 1,
	)
