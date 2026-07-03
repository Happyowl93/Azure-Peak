/**
 * The distiller - advanced alchemy.
 *
 * Where the cauldron brews *basic* potions from raw ingredients and water, the
 * distiller makes the advanced tier - the /datum/distiller_recipe potions, which a
 * plain cauldron refuses. To run one it needs, all at once:
 * - The recipe's base_reagent poured in as a liquid (water for stat potions, or the
 *   weaker potion for the "strong" variants), in sufficient quantity.
 * - Ingredients that smell of the target potion (scored exactly like the cauldron).
 * - A pinch of gold dust as the catalyst, which is required but NEVER consumed.
 */
/obj/machinery/light/rogue/distiller
	name = "distiller"
	desc = "A tangle of copper coils and blown glass over a great alembic. Where a cauldron brews base potions, a distiller refines them into far more potent elixirs."
	icon = 'icons/roguetown/misc/distillery.dmi'
	icon_state = "distillery0"
	base_state = "distillery"
	density = TRUE
	opacity = FALSE
	anchored = TRUE
	max_integrity = 300
	var/list/ingredients = list()
	var/maxingredients = 4
	/// The catalyst - a pinch of gold dust. Required to distill, never consumed.
	var/obj/item/alch/golddust/catalyst
	var/distilling = 0
	var/mob/living/carbon/human/lastuser
	fueluse = 20 MINUTES
	crossfire = FALSE
	roundstart_forbid = TRUE

/obj/machinery/light/rogue/distiller/Initialize()
	create_reagents(500, DRAINABLE | AMOUNT_VISIBLE | REFILLABLE)
	. = ..()

/obj/machinery/light/rogue/distiller/Destroy()
	if(catalyst)
		catalyst.forceMove(get_turf(src))
		catalyst = null
	for(var/obj/item/ing in ingredients)
		ing.forceMove(get_turf(src))
	ingredients = list()
	if(reagents)
		chem_splash(loc, 2, list(reagents))
		qdel(reagents)
	return ..()

/obj/machinery/light/rogue/distiller/burn_out()
	distilling = 0
	..()

/obj/machinery/light/rogue/distiller/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Pour a finished basic potion into the distiller with a container on the 'FEED' intent, the way you would fill a cauldron with water.")
	. += span_info("Then add ingredients that smell of the potion you wish to refine, and place a pinch of gold dust inside to act as a catalyst - it is not consumed.")

/// Tally the smell-points of the inserted ingredients, exactly like the cauldron.
/// Returns an associative list of recipe path = points, sorted descending (paths may be
/// cauldron or distiller recipes; the distiller only acts on the latter).
/obj/machinery/light/rogue/distiller/proc/score_ingredients()
	var/list/outcomes = list()
	for(var/obj/item/ing in ingredients)
		if(!istype(ing, /obj/item/alch))
			continue
		var/obj/item/alch/alching = ing
		if(alching.major_pot != null)
			if(outcomes[alching.major_pot] != null)
				outcomes[alching.major_pot] += 3
			else
				outcomes[alching.major_pot] = 3
		if(alching.med_pot != null)
			if(outcomes[alching.med_pot] != null)
				outcomes[alching.med_pot] += 2
			else
				outcomes[alching.med_pot] = 2
		if(alching.minor_pot != null)
			if(outcomes[alching.minor_pot] != null)
				outcomes[alching.minor_pot] += 1
			else
				outcomes[alching.minor_pot] = 1
	sortTim(outcomes, cmp=/proc/cmp_numeric_dsc, associative = 1)
	return outcomes

/obj/machinery/light/rogue/distiller/process()
	..()
	update_icon()
	if(!on)
		return
	if(!ingredients.len || !catalyst)
		return
	if(distilling < 20)
		if(reagents?.total_volume > 0)
			distilling++
			if(prob(10))
				playsound(src, "bubbles", 100, FALSE)
		return
	if(distilling != 20)
		return
	// distilling == 20: resolve the reaction.
	var/list/outcomes = score_ingredients()
	if(!outcomes.len || outcomes[outcomes[1]] < 5)
		distilling = 0
		visible_message(span_info("The mixture in [src] fails to bind together at all..."))
		playsound(src, 'sound/misc/smelter_fin.ogg', 30, FALSE)
		return
	var/winning_path = outcomes[1]
	if(!ispath(winning_path, /datum/distiller_recipe))
		distilling = 0
		visible_message(span_info("These ingredients would brew fine in a cauldron - the distiller does nothing with them."))
		playsound(src, 'sound/misc/smelter_fin.ogg', 30, FALSE)
		return
	var/datum/distiller_recipe/recipe = locate(winning_path) in GLOB.distiller_recipes
	if(!recipe)
		distilling = 0
		return
	if(!lastuser)
		distilling = 0
		visible_message(span_info("The distiller can't refine anything without an alchemist to guide it."))
		return
	// The base liquid must be present in sufficient quantity.
	if(reagents.get_reagent_amount(recipe.base_reagent) < recipe.base_reagent_amount)
		distilling = 0
		var/datum/reagent/base = recipe.base_reagent
		visible_message(span_warning("There isn't enough [initial(base.name)] in [src] to refine!"))
		playsound(src, 'sound/misc/smelter_fin.ogg', 30, FALSE)
		return
	// The catalyst must match.
	if(!istype(catalyst, recipe.catalyst))
		distilling = 0
		var/atom/needed = recipe.catalyst
		visible_message(span_warning("The reaction sputters out - it needs [initial(needed.name)] to catalyse."))
		playsound(src, 'sound/misc/smelter_fin.ogg', 30, FALSE)
		return
	var/amt2raise = lastuser?.STAINT * 2
	// Skill gate.
	if(recipe.skill_required > lastuser?.get_skill_level(/datum/skill/craft/alchemy))
		distilling = 0
		visible_message(span_warning("The elixir curdles into a ruined mess! A more skilled alchemist is needed for this refinement."))
		var/wasted = reagents.get_reagent_amount(recipe.base_reagent)
		reagents.remove_reagent(recipe.base_reagent, wasted)
		reagents.add_reagent(/datum/reagent/yuck, wasted)
		for(var/obj/item/ing in ingredients)
			qdel(ing)
		ingredients = list()
		lastuser?.adjust_experience(/datum/skill/craft/alchemy, amt2raise, FALSE) // Learn from failure.
		return
	// Success - spend the base liquid and the ingredients, keep the catalyst.
	// Clear ALL of the base reagent (not just the required amount), so leftover base
	// potion can't conflict with the freshly-made output and ruin it into sludge.
	reagents.remove_reagent(recipe.base_reagent, reagents.get_reagent_amount(recipe.base_reagent))
	for(var/obj/item/ing in ingredients)
		qdel(ing)
	ingredients = list()
	if(recipe.output_reagents.len)
		reagents.add_reagent_list(recipe.output_reagents)
	if(recipe.output_items.len)
		for(var/itempath in recipe.output_items)
			new itempath(get_turf(src))
	visible_message(span_info("The distiller settles with a faint [recipe.smells_like] smell, its work refined."))
	record_featured_stat(FEATURED_STATS_ALCHEMISTS, lastuser)
	record_round_statistic(STATS_POTIONS_BREWED)
	lastuser?.adjust_experience(/datum/skill/craft/alchemy, amt2raise, FALSE)
	playsound(src, "bubbles", 100, TRUE)
	playsound(src, 'sound/misc/smelter_fin.ogg', 30, FALSE)
	distilling = 21

/obj/machinery/light/rogue/distiller/attackby(obj/item/I, mob/user, params)
	// Gold dust is an /obj/item/alch, so catch it as the catalyst before the ingredient branch below.
	if(istype(I, /obj/item/alch/golddust))
		if(catalyst)
			to_chat(user, span_warning("There is already a catalyst in [src]."))
			return FALSE
		if(!user.transferItemToLoc(I, src))
			to_chat(user, span_warning("[I] is stuck to my hand!"))
			return FALSE
		catalyst = I
		distilling = 0
		lastuser = user
		to_chat(user, span_info("I set [I] into [src] as a catalyst."))
		return TRUE
	if(istype(I, /obj/item/alch))
		if(ingredients.len >= maxingredients)
			to_chat(user, span_warning("Nothing else can fit."))
			return FALSE
		if(!isnull(locate(I.type) in ingredients))
			to_chat(user, span_warning("There is already \a [I] in [src]! That would ruin the mixture!"))
			return FALSE
		if(!user.transferItemToLoc(I, src))
			to_chat(user, span_warning("[I] is stuck to my hand!"))
			return FALSE
		to_chat(user, span_info("I add [I] to [src]."))
		ingredients += I
		distilling = 0
		lastuser = user
		playsound(src, "bubbles", 100, TRUE)
		update_icon()
		return TRUE
	..()

/obj/machinery/light/rogue/distiller/attack_hand(mob/user, params)
	if(on)
		if(ingredients.len)
			to_chat(user, span_warning("Something's distilling."))
			return
		to_chat(user, span_info("Nothing's distilling."))
		return
	if(ingredients.len)
		var/obj/item/I = ingredients[ingredients.len]
		ingredients -= I
		I.loc = user.loc
		user.put_in_active_hand(I)
		user.visible_message(span_info("[user] pulls [I] from [src]."))
		return
	if(catalyst)
		var/obj/item/alch/golddust/gem = catalyst
		catalyst = null
		gem.loc = user.loc
		user.put_in_active_hand(gem)
		user.visible_message(span_info("[user] retrieves [gem] from [src]."))
		return
	to_chat(user, span_info("It's empty."))
	return ..()

/obj/machinery/light/rogue/distiller/onkick(mob/user)
	if(catalyst)
		catalyst.forceMove(get_turf(user))
		catalyst = null
	for(var/obj/item/in_still in ingredients)
		ingredients -= in_still
		in_still.forceMove(get_turf(user))
	if(reagents)
		chem_splash(loc, 2, list(reagents))
	user.visible_message(span_info("[user] kicks [src], spilling its contents!"))
	playsound(src, 'sound/items/beartrap2.ogg', 100, FALSE)
	return ..()
