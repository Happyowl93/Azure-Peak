/datum/species
	var/amtfail = 0

/datum/species/proc/get_accent_list(mob/living/carbon/human/H, type)
	switch(H.char_accent)
		if("No accent")
			return
		if("Dwarf accent")
			return strings("dwarfcleaner_replacement.json", type)
		if("Dwarf Gibberish accent")
			return strings("dwarf_replacement.json", type)
		if("Dark Elf accent")
			return strings("french_replacement.json", type)
		if("Elf accent")
			return strings("russian_replacement.json", type)
		if("Grenzelhoft accent")
			return strings("german_replacement.json", type)
		if("Hammerhold accent")
			return strings("Anglish.json", type)
		if("Assimar accent")
			return strings("proper_replacement.json", type)
		if("Lizard accent")
			return strings("brazillian_replacement.json", type)
		if("Tiefling accent")
			return strings("spanish_replacement.json", type)
		if("Half Orc accent")
			return strings("middlespeak.json", type)
		if("Urban Orc accent")
			return strings("norf_replacement.json", type)
		if("Hissy accent")
			return strings("hissy_replacement.json", type)
		if("Inzectoid accent")
			return strings("inzectoid_replacement.json", type)
		if("Feline accent")
			return strings("feline_replacement.json", type)
		if("Slopes accent")
			return strings("welsh_replacement.json", type)

/datum/species/proc/get_accent(mob/living/carbon/human/H)
	return get_accent_list(H,"full")

/datum/species/proc/get_accent_any(mob/living/carbon/human/H) //determines if accent replaces in-word text
	return get_accent_list(H,"syllable")

/datum/species/proc/get_accent_start(mob/living/carbon/human/H)
	return get_accent_list(H,"start")

/datum/species/proc/get_accent_end(mob/living/carbon/human/H)
	return get_accent_list(H,"end")

/// Holds a pre-compiled alternation regex and its replacement lookup table.
/datum/accent_regex_data
	var/regex/pattern
	/// Assoc list: lowercase key -> replacement (text or list of text options).
	var/list/lookup

/// Global cache of pre-compiled accent regex data, keyed by "[filename]|[section]".
/// A null entry means the section was checked and has no content.
GLOBAL_LIST_EMPTY(accent_regex_cache)

/// Active accent data during a regex.Replace callback (single-threaded, safe).
GLOBAL_VAR(accent_current_data)

/**
 * Species speech handler registered on COMSIG_MOB_SAY. Applies accent word
 * replacement before autopunctuation.
 *
 * The universal accent (slang/lore terminology) applies to all speakers.
 * The per-character accent applies based on the player's selected char_accent.
 *
 * Arguments:
 * * source - The mob that is speaking.
 * * speech_args - The COMSIG_MOB_SAY argument list (SPEECH_MESSAGE is modified in place).
 */
/datum/species/proc/handle_speech(datum/source, list/speech_args)
	var/mob/living/carbon/human/H = source
	var/message = speech_args[SPEECH_MESSAGE]
	if(!message)
		return

	// Universal accent (applies to all speakers).
	message = treat_message_accent(message, "accent_universal.json", "universal")

	// Per-character accent (applies if the player selected one).
	// Accent files use varying section key names (e.g. "full", "dwarf", "start",
	// "end", "syllable"), so we iterate whatever sections exist in the file.
	if(H?.char_accent && H.char_accent != "No accent")
		var/accent_file = get_accent_file(H.char_accent)
		if(accent_file)
			load_strings_file(accent_file)
			var/list/file_data = GLOB.string_cache?[accent_file]
			if(file_data)
				for(var/section in file_data)
					message = treat_message_accent(message, accent_file, section)

	message = autopunct_bare(message)

	speech_args[SPEECH_MESSAGE] = trim(message)

/**
 * Maps a character accent name to its JSON dictionary filename.
 *
 * Arguments:
 * * accent_name - The accent name from GLOB.character_accents.
 * Returns: The filename string, or null if no file is associated.
 */
/datum/species/proc/get_accent_file(accent_name)
	switch(accent_name)
		if("Dwarf accent")
			return "dwarfcleaner_replacement.json"
		if("Dwarf Gibberish accent")
			return "dwarf_replacement.json"
		if("Dark Elf accent")
			return "french_replacement.json"
		if("Elf accent")
			return "russian_replacement.json"
		if("Grenzelhoft accent")
			return "german_replacement.json"
		if("Hammerhold accent")
			return "Anglish.json"
		if("Assimar accent")
			return "proper_replacement.json"
		if("Lizard accent")
			return "brazillian_replacement.json"
		if("Tiefling accent")
			return "spanish_replacement.json"
		if("Half Orc accent")
			return "middlespeak.json"
		if("Urban Orc accent")
			return "norf_replacement.json"
		if("Hissy accent")
			return "hissy_replacement.json"
		if("Inzectoid accent")
			return "inzectoid_replacement.json"
		if("Feline accent")
			return "feline_replacement.json"
		if("Slopes accent")
			return "welsh_replacement.json"

/**
 * Applies accent word replacement using a single pre-compiled alternation regex
 * (cached per file+section).
 * Arguments:
 * * message - The speech message to transform.
 * * filename - The JSON filename (in strings/) with the accent dictionary.
 * * section - The dictionary key within the JSON (e.g. "universal", "full",
 *   "dwarf", "start", "end", "syllable").
 * Returns: The transformed message, or the original if no replacements apply.
 */
/proc/treat_message_accent(message, filename, section)
	if(!message)
		return message
	if(message[1] == "*")
		return message

	var/datum/accent_regex_data/data = get_accent_regex_data(filename, section)
	if(!data)
		return message

	GLOB.accent_current_data = data
	. = data.pattern.Replace(message, GLOBAL_PROC_REF(accent_replace_callback))
	GLOB.accent_current_data = null

/**
 * Builds (once) and caches the pre-compiled alternation regex + lookup for a
 * file+section. Returns null if the section is empty or doesn't exist.
 *
 * Arguments:
 * * filename - The JSON filename (in strings/).
 * * section - The dictionary key within the JSON.
 * Returns: /datum/accent_regex_data, or null if the section has no content.
 */
/proc/get_accent_regex_data(filename, section)
	var/cache_key = "[filename]|[section]"
	if(cache_key in GLOB.accent_regex_cache)
		return GLOB.accent_regex_cache[cache_key]

	load_strings_file(filename)
	var/list/file_data = GLOB.string_cache?[filename]
	var/list/dict = file_data?[section]
	if(!dict || !length(dict))
		GLOB.accent_regex_cache[cache_key] = null
		return null

	var/list/parts = list()
	var/list/lookup = list()
	for(var/key in dict)
		parts += regex_escape_accent(key)
		var/value = dict[key]
		lookup[lowertext(key)] = value

	var/alternation = jointext(parts, "|")
	var/pattern_str
	switch(section)
		if("start")
			pattern_str = "\\b([alternation])"
		if("end")
			pattern_str = "([alternation])\\b"
		if("syllable")
			pattern_str = "([alternation])"
		else
			pattern_str = "\\b([alternation])\\b"

	var/datum/accent_regex_data/data = new /datum/accent_regex_data()
	data.pattern = regex(pattern_str, "ig")
	data.lookup = lookup

	GLOB.accent_regex_cache[cache_key] = data
	return data

/**
 * Callback for regex.Replace. Looks up the matched word (case-insensitively)
 * and returns the replacement with the original word's casing preserved.
 *
 * Arguments:
 * * match - The full regex match (returned unchanged if no replacement exists).
 * * captured - The captured group (the key word from the alternation).
 * Returns: The replacement text, or the original match.
 */
/proc/accent_replace_callback(match, captured)
	var/datum/accent_regex_data/data = GLOB.accent_current_data
	if(!data)
		return match
	var/replacement = data.lookup?[lowertext(captured)]
	if(isnull(replacement))
		return match
	if(islist(replacement))
		replacement = pick(replacement)
	if(captured == uppertext(captured))
		return uppertext(replacement)
	if(captured == capitalize(captured))
		return capitalize(replacement)
	return replacement

/// Escapes regex metacharacters in text so it can be used as a literal pattern.
/// Uses ascii2text to build the metacharacters at runtime, because [ and ] inside
/// DM string literals are interpreted as embedded-expression interpolation.
/proc/regex_escape_accent(text)
	var/static/list/meta_chars
	if(isnull(meta_chars))
		// ASCII codes for: \ . + * ? ( ) [ ] { } | ^ $
		var/static/list/meta_codes = list(92, 46, 43, 42, 63, 40, 41, 91, 93, 123, 125, 124, 94, 36)
		meta_chars = list()
		for(var/code in meta_codes)
			meta_chars += ascii2text(code)
	. = text
	var/static/backslash = ascii2text(92)
	for(var/c in meta_chars)
		. = replacetext(., c, backslash + c)
