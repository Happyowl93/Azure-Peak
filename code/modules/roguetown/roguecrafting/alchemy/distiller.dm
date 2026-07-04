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
	var/maxingredients = 6
	/// The catalyst - a pinch of gold dust. Required to distill, never consumed.
	var/obj/item/alch/golddust/catalyst
	/// Item types accepted in the catalyst slot. Add new catalysts here.
	var/static/list/catalyst_types = list(/obj/item/alch/golddust)
	/// A player-fitted vessel (bucket/bottle/etc.) that catches the finished elixir, keeping it clear of the leftover base liquid.
	var/obj/item/reagent_containers/glass/output_container
	/// Heat-up counter, counts up to [heatup_ticks] before a locked-in batch starts dripping.
	var/distilling = 0
	/// Process ticks of heat-up before the first drop forms.
	var/heatup_ticks = 10
	/// The recipe currently dripping out. While set, the machine is in its drip phase.
	var/datum/distiller_recipe/active_recipe
	/// Output reagents still to drip this batch (reagent path -> units remaining).
	var/list/drip_remaining
	/// Units of elixir that drip out per process tick.
	var/drip_rate = 6
	/// Colour of the current elixir, used to tint the falling-drip overlay.
	var/drip_color = "#ffffff"
	/// Set once we've warned that drips are spilling, so the warning doesn't spam.
	var/overflow_warned = FALSE
	var/mob/living/carbon/human/lastuser
	fueluse = 20 MINUTES
	crossfire = FALSE
	roundstart_forbid = TRUE

/obj/machinery/light/rogue/distiller/Initialize()
	// No AMOUNT_VISIBLE - examine() below reports the contents (and their identity) itself.
	create_reagents(270, DRAINABLE | REFILLABLE)
	. = ..()

/obj/machinery/light/rogue/distiller/examine(mob/user)
	. = ..()
	// The catalyst cradle.
	if(catalyst)
		. += span_info("[catalyst.name] rests in the catalyst cradle.")
	else
		. += span_warning("The catalyst cradle is empty.")
	// The base liquid held in the alembic.
	if(reagents?.total_volume)
		var/list/held = list()
		for(var/datum/reagent/R as anything in reagents.reagent_list)
			held += "[round(R.volume)] [UNIT_FORM_STRING(round(R.volume))] of <font color=[R.color]>[R.name]</font>"
		. += span_info("The alembic holds [english_list(held)].")
	else
		. += span_info("The alembic is dry.")
	// The ingredients steeping inside.
	if(length(ingredients))
		var/list/ing_names = list()
		for(var/obj/item/I as anything in ingredients)
			ing_names += I.name
		. += span_info("Steeping within ([length(ingredients)]/[maxingredients]): [english_list(ing_names)].")
	else
		. += span_info("No ingredients have been added.")
	// The output vessel fitted to the spout.
	if(output_container)
		if(output_container.reagents?.total_volume)
			var/list/caught = list()
			for(var/datum/reagent/R as anything in output_container.reagents.reagent_list)
				caught += "[round(R.volume)] [UNIT_FORM_STRING(round(R.volume))] of <font color=[R.color]>[R.name]</font>"
			. += span_info("[output_container.name] is fitted to the spout, holding [english_list(caught)].")
		else
			. += span_info("An empty [output_container.name] is fitted to the spout.")
	else
		. += span_warning("No vessel is fitted to the spout to catch the elixir.")
	// Whether a batch is currently dripping.
	if(active_recipe)
		. += span_info("It is busy distilling, elixir dripping from the spout.")

/obj/machinery/light/rogue/distiller/Destroy()
	if(catalyst)
		catalyst.forceMove(get_turf(src))
		catalyst = null
	if(output_container)
		output_container.forceMove(get_turf(src))
		output_container = null
	for(var/obj/item/ing in ingredients)
		ing.forceMove(get_turf(src))
	ingredients = list()
	if(reagents)
		chem_splash(loc, 2, list(reagents))
		qdel(reagents)
	return ..()

/obj/machinery/light/rogue/distiller/update_icon()
	..() // sets the base distillery0/distillery1 icon_state
	cut_overlays()
	// Bucket gets its own overlay; every other glass vessel shows the bottle.
	if(output_container)
		var/overlay_state = istype(output_container, /obj/item/reagent_containers/glass/bucket) ? "out_bucket" : "out_bottle"
		add_overlay(mutable_appearance(icon, overlay_state))
	// While actively distilling, drops fall from the spout, tinted the elixir's colour.
	if(active_recipe && on)
		var/mutable_appearance/drip = mutable_appearance(icon, "distillery_drip")
		drip.color = drip_color
		add_overlay(drip)

/obj/machinery/light/rogue/distiller/burn_out()
	distilling = 0
	..()

/obj/machinery/light/rogue/distiller/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Pour a finished basic potion into the distiller with a container on the 'FEED' intent, the way you would fill a cauldron with water.")
	. += span_info("Then add ingredients that smell of the potion you wish to refine, and place a pinch of gold dust inside to act as a catalyst - it is not consumed.")
	. += span_info("Right-click the distiller with a glass vessel in hand to slot it under the spout. Once distilling begins the elixir drips into it slowly; you can remove and swap vessels mid-batch by left-clicking the machine. Overflow is wasted.")
	. += span_info("Loading more ingredients that smell of the target potion scales the yield.")

/obj/machinery/light/rogue/distiller/process()
	..()
	if(!on)
		return
	// Drip phase: a batch is locked in and slowly filling the vessel.
	if(active_recipe)
		process_drip()
		return
	// Otherwise, heat up toward starting a new batch.
	if(!ingredients.len || !catalyst)
		return
	if(distilling < heatup_ticks)
		if(reagents?.total_volume > 0)
			distilling++
			if(prob(10))
				playsound(src, "bubbles", 100, FALSE)
		return
	// Heat-up complete - validate the batch and either begin dripping or fail.
	try_begin_distillation()

/// Validate the loaded ingredients/base/catalyst once heat-up finishes, and if they make a
/// valid recipe, commit the reaction so it can drip into the vessel over the coming ticks.
/obj/machinery/light/rogue/distiller/proc/try_begin_distillation()
	var/list/outcomes = score_alch_ingredients(ingredients)
	if(!outcomes.len || outcomes[outcomes[1]] < 5)
		distilling = 0
		visible_message(span_info("The mixture in [src] fails to bind together at all..."))
		playsound(src, 'sound/misc/smelter_fin.ogg', 30, FALSE)
		// Consume the ingredients so the machine doesn't re-heat and re-fail forever.
		for(var/obj/item/ing in ingredients)
			qdel(ing)
		ingredients = list()
		return
	var/datum/winning = outcomes[1]
	var/winning_score = outcomes[winning]
	if(!istype(winning, /datum/distiller_recipe))
		distilling = 0
		visible_message(span_info("These ingredients would brew fine in a cauldron - the distiller does nothing with them."))
		playsound(src, 'sound/misc/smelter_fin.ogg', 30, FALSE)
		// Consume the ingredients so the machine doesn't re-heat and re-fail forever.
		for(var/obj/item/ing in ingredients)
			qdel(ing)
		ingredients = list()
		return
	var/datum/distiller_recipe/recipe = winning
	if(!lastuser)
		distilling = 0
		visible_message(span_info("The distiller can't refine anything without an alchemist to guide it."))
		return
	// Scale output linearly: total output = winning_score × recipe.potency_per_score.
	// Strong potions/poisons: 15/score (score 18 → 270u). Stat potions: 7.5/score (half).
	var/total_output = winning_score * recipe.potency_per_score
	var/available_base = reagents.get_reagent_amount(recipe.base_reagent)
	if(available_base <= 0)
		distilling = 0
		var/datum/reagent/base = recipe.base_reagent
		visible_message(span_warning("The mixture reeks of [recipe.smells_like] - but there's no [initial(base.name)] in [src] to refine it into [recipe.name]!"))
		playsound(src, 'sound/misc/smelter_fin.ogg', 30, FALSE)
		// Consume the ingredients so the machine doesn't re-heat and re-fail forever.
		for(var/obj/item/ing in ingredients)
			qdel(ing)
		ingredients = list()
		return
	// Figure out how much base this much output would need, then process whatever's
	// available. If base falls short, output scales down proportionally — the rest
	// of the ingredient score is simply discarded.
	var/standard_output = 0
	for(var/rpath in recipe.output_reagents)
		standard_output += recipe.output_reagents[rpath]
	var/base_per_output = standard_output > 0 ? recipe.base_reagent_amount / standard_output : 1
	var/max_output_from_base = available_base / base_per_output
	var/actual_output = min(total_output, max_output_from_base)
	var/base_to_consume = actual_output * base_per_output
	var/output_multiplier = standard_output > 0 ? actual_output / standard_output : 1
	// The catalyst must match.
	if(!istype(catalyst, recipe.catalyst))
		distilling = 0
		var/atom/needed = recipe.catalyst
		visible_message(span_warning("The reaction sputters out, it needs [initial(needed.name)] to catalyse."))
		playsound(src, 'sound/misc/smelter_fin.ogg', 30, FALSE)
		// Consume the ingredients so the machine doesn't re-heat and re-fail forever.
		for(var/obj/item/ing in ingredients)
			qdel(ing)
		ingredients = list()
		return
	var/amt2raise = lastuser?.STAINT * 2
	// Skill gate.
	if(recipe.skill_required > lastuser?.get_skill_level(/datum/skill/craft/alchemy))
		distilling = 0
		visible_message(span_warning("The [recipe.smells_like] elixir curdles into a ruined mess! A more skilled alchemist is needed to refine [recipe.name]."))
		var/wasted = reagents.get_reagent_amount(recipe.base_reagent)
		reagents.remove_reagent(recipe.base_reagent, wasted)
		reagents.add_reagent(/datum/reagent/yuck, wasted)
		for(var/obj/item/ing in ingredients)
			qdel(ing)
		ingredients = list()
		lastuser?.adjust_experience(/datum/skill/craft/alchemy, amt2raise, FALSE) // Learn from failure.
		return
	// Commit the reaction. Consume the base (capped by what's available) and scale
	// the elixir yield to match. Ingredients are always fully consumed.
	reagents.remove_reagent(recipe.base_reagent, base_to_consume)
	for(var/obj/item/ing in ingredients)
		qdel(ing)
	ingredients = list()
	active_recipe = recipe
	drip_remaining = list()
	for(var/rpath in recipe.output_reagents)
		drip_remaining[rpath] = recipe.output_reagents[rpath] * output_multiplier
	overflow_warned = FALSE
	distilling = 0
	// Tint the falling drops with the first output reagent's colour.
	drip_color = "#ffffff"
	for(var/dpath in recipe.output_reagents)
		var/datum/reagent/DR = dpath
		drip_color = initial(DR.color)
		break
	// Physical item outputs aren't liquids to drip, so spawn them right away.
	if(recipe.output_items.len)
		for(var/itempath in recipe.output_items)
			new itempath(get_turf(src))
	// Reward the alchemist for the successful refinement.
	record_featured_stat(FEATURED_STATS_ALCHEMISTS, lastuser)
	record_round_statistic(STATS_POTIONS_BREWED)
	lastuser?.adjust_experience(/datum/skill/craft/alchemy, amt2raise, FALSE)
	visible_message(span_info("[src] shudders and begins to drip a faint [recipe.smells_like] elixir."))
	playsound(src, "bubbles", 100, TRUE)
	update_icon()

/// Drip a measure of each pending output reagent into the fitted vessel. Anything that
/// doesn't fit - because the vessel is full or none is fitted - spills out and is lost.
/obj/machinery/light/rogue/distiller/proc/process_drip()
	var/any_left = FALSE
	var/spilled = FALSE
	for(var/rpath in drip_remaining)
		var/amount = drip_remaining[rpath]
		if(amount <= 0)
			continue
		var/this_drip = min(amount, drip_rate)
		drip_remaining[rpath] = amount - this_drip
		if((amount - this_drip) > 0)
			any_left = TRUE
		// How much of this drip can the vessel actually hold?
		var/landed = 0
		if(output_container?.reagents)
			var/room = output_container.reagents.maximum_volume - output_container.reagents.total_volume
			landed = min(this_drip, max(room, 0))
			if(landed > 0)
				output_container.reagents.add_reagent(rpath, landed)
		if(landed < this_drip)
			spilled = TRUE
	if(spilled && !overflow_warned)
		overflow_warned = TRUE
		if(output_container)
			visible_message(span_warning("[output_container] is full - the elixir overflows and is lost!"))
		else
			visible_message(span_warning("The elixir drips from the spout with no vessel to catch it, and is lost!"))
	if(prob(25))
		playsound(src, "bubbles", 60, FALSE)
	if(!any_left)
		finish_distillation()

/// End the current batch, whether the vessel caught it all or some spilled.
/obj/machinery/light/rogue/distiller/proc/finish_distillation()
	if(active_recipe)
		visible_message(span_info("The distiller settles, its [active_recipe.smells_like] work complete."))
		playsound(src, 'sound/misc/smelter_fin.ogg', 30, FALSE)
	active_recipe = null
	drip_remaining = null
	overflow_warned = FALSE
	distilling = 0
	update_icon()

/obj/machinery/light/rogue/distiller/attackby(obj/item/I, mob/user, params)
	// A catalyst item seats in the slot when it's empty; any extra falls through and loads as a normal ingredient.
	if(!catalyst && is_type_in_list(I, catalyst_types))
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
	if(istype(I, /obj/item/reagent_containers/glass))
		// Only fit the vessel on the default intent; POUR/fill/splash still drive the normal fill-and-drain.
		if(user.used_intent?.type != INTENT_GENERIC)
			return ..()
		if(output_container)
			to_chat(user, span_warning("There is already a vessel fitted to [src]."))
			return FALSE
		if(!user.transferItemToLoc(I, src))
			to_chat(user, span_warning("[I] is stuck to my hand!"))
			return FALSE
		output_container = I
		lastuser = user
		to_chat(user, span_info("I fit [I] to [src] to catch the elixir."))
		update_icon()
		return TRUE
	..()

/obj/machinery/light/rogue/distiller/attack_right(mob/user)
	// Right-click with a glass vessel in hand to slot it as the output container,
	// so players don't have to "strike" the machine with it on the default intent.
	var/obj/item/I = user.get_active_held_item()
	if(istype(I, /obj/item/reagent_containers/glass))
		if(output_container)
			to_chat(user, span_warning("There is already a vessel fitted to [src]."))
			return FALSE
		if(!user.transferItemToLoc(I, src))
			to_chat(user, span_warning("[I] is stuck to my hand!"))
			return FALSE
		output_container = I
		lastuser = user
		to_chat(user, span_info("I fit [I] to [src] to catch the elixir."))
		update_icon()
		return TRUE
	return ..()

/obj/machinery/light/rogue/distiller/attack_hand(mob/user, params)
	if(on)
		// Allow removing the output vessel even while the distiller is running, so
		// alchemists can swap in a fresh container to catch the rest of a batch.
		if(output_container)
			var/obj/item/reagent_containers/glass/vessel = output_container
			output_container = null
			vessel.loc = user.loc
			user.put_in_active_hand(vessel)
			user.visible_message(span_info("[user] removes [vessel] from [src]."))
			overflow_warned = FALSE // Re-enable the overflow warning for the next vessel.
			update_icon()
			return
		if(ingredients.len || active_recipe)
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
	if(output_container)
		var/obj/item/reagent_containers/glass/vessel = output_container
		output_container = null
		vessel.loc = user.loc
		user.put_in_active_hand(vessel)
		user.visible_message(span_info("[user] removes [vessel] from [src]."))
		overflow_warned = FALSE // Re-enable the overflow warning for the next vessel.
		update_icon()
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
	if(output_container)
		output_container.forceMove(get_turf(user))
		output_container = null
	for(var/obj/item/in_still in ingredients)
		ingredients -= in_still
		in_still.forceMove(get_turf(user))
	if(reagents)
		chem_splash(loc, 2, list(reagents))
	user.visible_message(span_info("[user] kicks [src], spilling its contents!"))
	playsound(src, 'sound/items/beartrap2.ogg', 100, FALSE)
	update_icon()
	return ..()
