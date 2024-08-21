function scr_load_game_data() {
	//This script will load the strings into the battle map list
	show_debug_message("running scr_load_game_data")

	ini_open("battle_map_strings.ini");

	//How many maps were saved
	total_maps = ini_read_real("Total Maps", "Value", total_maps);

	for (var i = 0; i < total_maps; i ++){
		var str = ini_read_string("Data String", string(i), "");
		battle_map_list[| i] = str;
	
		//show_debug_message(str);
	}

	ini_close();

	//If a map exists in the first slot of the list, load it

	if (ds_list_size(battle_map_list) > 0){
		show_debug_message("saved map found, loading");
		scr_load_map(0, ds_terrain_data, battle_map_list);
	}else show_debug_message("No saved maps found");

}
