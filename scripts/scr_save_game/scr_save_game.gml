/// @function scr_save_game(save_slot)
function scr_save_game(save_slot){
	
	show_debug_message("SAVE GAME SCRIPT RUNNING");
	var fname = "tactics_save_" + string(save_slot) + ".txt";
	
	var date = date_datetime_string(date_current_datetime());
			   
	var file = file_text_open_write(working_directory + fname);
	
	var character_stats = ds_grid_write(global.character_stats);
	var inventory = ds_list_write(global.inventory);
	var world_values = ds_list_write(global.ds_values);
	
	file_text_write_string(file, date);
	file_text_writeln(file);
	file_text_write_string(file, character_stats);
	file_text_writeln(file);
	file_text_write_string(file, inventory);
	file_text_writeln(file);
	file_text_write_string(file, world_values);
	
	file_text_close(file);
	
	//Update Save Slot text
	scr_update_save_slot_text();
}