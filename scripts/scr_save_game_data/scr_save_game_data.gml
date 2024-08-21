function scr_save_game_data() {
	//This script will save the strings that the list holds

	ini_open("battle_map_strings.ini");

	for (var i = 0; i < ds_list_size(battle_map_list); i ++){
		ini_write_string("Data String", string(i), battle_map_list[| i]);
	}

	ini_write_real("Total Maps", "Value", ds_list_size(battle_map_list));

	ini_close();

	show_debug_message("scr_save_game_data finished");


}
