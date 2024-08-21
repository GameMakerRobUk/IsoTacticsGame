/// @description LOAD GAME DATA / NEW GAME

#region LOAD DATA / NEW GAME	

if (room == rm_world_map && global.main_state != e_main_states.game_ready){
	
	if (global.main_state == e_main_states.load_game){
		
		scr_load_saved_game(global.current_save_file);
		global.main_state = e_main_states.game_ready;
	}else{
		if (global.main_state == e_main_states.new_game){
			//We want to save AFTER the player has been created
			global.ds_values[| e_values_to_track.player_sprite] = obj_player.sprite_index; 
			global.ds_values[| e_values_to_track.player_x] = obj_player.x;
			global.ds_values[| e_values_to_track.player_y] = obj_player.y;
			
			scr_save_game(global.current_save_file);
			
			global.main_state = e_main_states.game_ready;
		}	
	}
}

#endregion

