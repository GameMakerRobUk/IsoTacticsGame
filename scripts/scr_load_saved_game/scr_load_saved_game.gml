/// @function scr_load_saved_game(save_slot)
function scr_load_saved_game(save_slot){
	
	show_debug_message("SCR_LOAD_SAVED_GAME RUNNING");
	var fname = "tactics_save_" + string(save_slot) + ".txt";
			   
	var file = file_text_open_read(working_directory + fname);
	
	file_text_readln(file); //DATE IS THE FIRST LINE
	var character_stats = file_text_read_string(file); //CHARACTER STATS SECOND LINE
	file_text_readln(file);
	var inventory = file_text_read_string(file); //INVENTORY THIRD LINE
	file_text_readln(file); 
	var world_values = file_text_read_string(file); //WORLD VALUES FOURTH LINE
	
	//show_debug_message("story state before load: " + string(global.ds_values[| e_values_to_track.story_state]));
	
	//CONVERT THESE 3 STRINGS INTO USABLE DATA
	ds_grid_read(global.character_stats, character_stats);
	ds_list_read(global.inventory, inventory);
	ds_list_read(global.ds_values, world_values);
	
	//show_debug_message("story state after load: " + string(global.ds_values[| e_values_to_track.story_state]));
	
	file_text_close(file);
	
	with obj_player{				
		x = global.ds_values[| e_values_to_track.player_x];
		y = global.ds_values[| e_values_to_track.player_y];
		sprite_index = global.ds_values[| e_values_to_track.player_sprite] ;
	}
	
}