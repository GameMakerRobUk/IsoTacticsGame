/// @function scr_delete_map(map_number, list_of_battle_maps)
/// @description delete a map!
/// @param {real} map_number - the number of the map we're deleting (this is the entry in the battle map list)
/// @param {real} list_of_battle_maps - what's the name of the list that holds all our battle map strings
function scr_delete_map(map_number, list_of_battle_maps) {

	//Remove string from list
	ds_list_delete(list_of_battle_maps, map_number);

	if (map_number >= ds_list_size(list_of_battle_maps) ) map_number = (ds_list_size(list_of_battle_maps) - 1);

	return map_number;

	show_debug_message("Map deleted");


}
