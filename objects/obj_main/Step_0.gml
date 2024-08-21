if (sprites_created && room == rm_first){

	if (game_state == e_game_states.game){
        //If on Title screen and pressed enter, go to Saved Game screen
		if (global.main_state == e_main_states.title_screen){
			if (keyboard_check_pressed(vk_enter) ){
				global.main_state = e_main_states.display_save_files;	
			}
		}else{

			if (global.main_state == e_main_states.display_save_files){
		
				#region CHOOSE/DELETE/START/LOAD A SAVE FILE
		
				if (keyboard_check_pressed(vk_up) || keyboard_check_pressed(vk_down) ){
					global.current_save_file = scr_change_option(global.current_save_file, 0, 2, 1);	
				}
		
				if (keyboard_check_pressed(vk_enter)){
					//Is this save file empty or not?
					var fname = "tactics_save_" + string(global.current_save_file) + ".txt";
					if file_exists(fname){
						//load game	
				
						global.main_state = e_main_states.load_game; 
						room_goto(rm_world_map);					 

					}else{
						//new game	
				
						global.main_state = e_main_states.new_game; 
						room_goto(rm_world_map);					

					}
				}
		
				if (keyboard_check_pressed(vk_backspace) ){
			
					#region DELETE SAVE SLOT
			
					var fname = "tactics_save_" + string(global.current_save_file) + ".txt";
			
					if file_exists(fname){
    
						show_debug_message("Deleting " + fname);
						file_delete(fname);
						scr_update_save_slot_text();	
					}else show_debug_message(fname + " does not exist, can't delete");
		    
					#endregion
			
				}
		
				#endregion
		
			}
	
		}

		if (global.main_state == e_main_states.credits){  
	
			#region CREDITS   
	
			credit_y --;
	
			if (credit_y <= 0 - (array_length(a_credits) * 40) ){
				//save the game
				scr_save_game(global.current_save_file);
		
				//go to title screen
				global.main_state = e_main_states.title_screen;
				room_goto(rm_first);
			}
	
			#endregion
		}

	}else{
		//Go to Editor/Testing
		show_debug_message("Go to editing/testing - room_now: " + string(room) );
		if (game_state == e_game_states.editing) room_goto(rm_editor);
		if (game_state == e_game_states.testing) room_goto(rm_testing);
	}

}