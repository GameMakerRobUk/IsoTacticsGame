/// @function scr_sort_stats(list)
/// @description Add selected stats to a list so that they can be displayed (just the enums, not the ACTUAL values of the current unit)
/// @param {real} list - which list will hold the stats
function scr_sort_stats(list) {

	/*
		stat_values are the values stored in global.character_stats
		The reason we just add the enums is because we want to know what text to draw as WELL AS the stat values, this was the easiest way.
		We could have used the top line of the classes_and_characters.csv for text but I wanted to keep that line as descriptive as possible
	*/

	ds_list_add(list, e_stats.class, e_stats.hp_max, e_stats.mp_max, e_stats.level, e_stats.xp, e_stats.strength, e_stats.intelligence, e_stats.defence,
					  e_stats.wisdom, e_stats.accuracy, e_stats.agility, e_stats.block_chance_melee, e_stats.block_chance_ranged, e_stats.fire_resist,e_stats.ice_resist);
}
