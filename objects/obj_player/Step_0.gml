if (state == e_player_states.init && global.main_state == e_main_states.game_ready){ 
	
	#region INIT																	
	
	//Create Array to store path id's and their point
	with (obj_world_point){
		//Whatever the path point of this world_point it, save its id to that entry in the players array
		other.path_array[path_point] = id;
	}
	
	//CHECK WHICH PATH POINT WE'RE ON
	path_point = collision_point(x, y, obj_world_point, false, true);
	//prev_path_point = path_point;
	
	//MAKE SURE THAT THE ARRAY IS CREATED PROPERLY
	for (var i = 0; i < array_length_1d(path_array); i ++){
		show_debug_message("path_array[" + string(path_array[i]) + "]");	
	}
	
	//We have a cutscene at the start of the game so we want to go straight to the walking state to launch it	
	if (global.ds_values[| e_values_to_track.story_state] == e_story.a_debriefing){
		state = e_player_states.walking;
		//mouse_over_path = path_point;		
		target_path_point = path_point;
	}else{
		//GO TO DEFAULT STATE
		show_debug_message("Setting player state to idle from init");
		state = e_player_states.idle;
	}
	
	#endregion
	
}

if (state == e_player_states.idle){
	
	#region IDLE																					
	
	if (keyboard_check_pressed(vk_enter) ){
		
		#region SET STATE TO MENU																		
			
		state = e_player_states.world_menu;	
		highlighted_option = e_world_actions.army;
		
		#endregion
		
	}else{
	
		#region CHOOSE A PATH POINT TO MOVE TO		
		
		if (keyboard_check_pressed(vk_left) ){
			if (selected_option > 0) selected_option --;
			else selected_option = ds_list_size(path_point.connects_to) - 1;
		}
		
		if (keyboard_check_pressed(vk_right) ){
			if (selected_option + 1) < ds_list_size(path_point.connects_to) selected_option ++;
			else selected_option = 0;
		}
		
		if (keyboard_check_pressed(vk_left) || keyboard_check_pressed(vk_right) ){
			//prev_path_point = connecting_path_point; //I want to check to see if we actually picked a different path point or if we're still selecting the one that the player is on
			connecting_path_point = path_point.connects_to[| selected_option];
			target_path_point = path_array[connecting_path_point];
			
			with obj_world_point{
				image_index = 0;
				if (id == other.target_path_point) image_index = 1;	
			}
			
		}
		
		if (keyboard_check_pressed(vk_space) && path_point != target_path_point){
			//show_message("connecting_path_point: " + string(connecting_path_point) + " | prev_path_point: " + string(prev_path_point) );
			move_towards_point(target_path_point.x, target_path_point.y, 1);
			state = e_player_states.walking;
			
			#region SET SPRITE	
				
			/*
						90
					180	   0
					    270
			*/
			var dir = point_direction(x, y, target_path_point.x, target_path_point.y);
																														
			if (dir >= 90 && dir < 180) sprite_index = char_grid[# e_actor_sprites.idle, e_facing.west];
			if (dir >= 0 && dir < 90) sprite_index = char_grid[# e_actor_sprites.idle, e_facing.north];
			if (dir >= 270 && dir < 360) sprite_index = char_grid[# e_actor_sprites.idle, e_facing.east];
			if (dir >= 180 && dir < 270) sprite_index = char_grid[# e_actor_sprites.idle, e_facing.south];
				
			#endregion
		}
		
		#endregion
	}
	
	#endregion
	
}else{ 

	if (state == e_player_states.walking){
	
		#region WALKING																			 
	
		//Stop player if he reaches target

		if (abs(x - target_path_point.x) <= 1 && abs(y - target_path_point.y) <= 1){ 
			speed = 0;	
			path_point = collision_point(x, y, obj_world_point, false, true);
			state = e_player_states.idle;
			
			#region SAVE PLAYER X/Y AND SPRITE				
			
			global.ds_values[| e_values_to_track.player_x] = x;
			global.ds_values[| e_values_to_track.player_y] = y;
			global.ds_values[| e_values_to_track.player_sprite] = sprite_index;
			
			#endregion
		
			#region Check for cut scene / battle													
		
			var story_state = global.ds_values[| e_values_to_track.story_state];					
			var column_to_check = (path_point.path_point) * e_path_point_setup.last;				
			var map = real ( global.story_points[# column_to_check, story_state] );
			var map_type = real ( global.story_points[# column_to_check + 1, story_state] );       
		
			if ( map_type != -1 && map_type != e_map_types.shop){
				//It's a battle or story scene
				with obj_scene{
					if (map_type == e_map_types.battle) state = e_misc_states.setup_battle; else state = e_misc_states.conversation	
					map_type_ = map_type;																										
					scr_load_map(map, ds_terrain_data, battle_map_list);	
					show_map = true;
				
					#region Setup conversation variables													
				
					var csv = global.story_points[# column_to_check + e_path_point_setup.conversation_csv, story_state];
					conversation = load_csv(csv);
					conversation_entry = 0;
				
					text = conversation[# 0, conversation_entry];
					speaker = real(string_digits(text));
				
					//Center map on first talker		
					unit = scr_center_on_speaker(speaker, ds_terrain_data);		
					
					if (unit != noone){
						unit_name = global.character_stats[# e_stats.name, unit];		
						show_debug_message("unit_name player steo line 122: " + string(unit_name));
						//Remove digits from string
						scr_remove_digits();
					}else{
						show_message("There is no unit data for this map, returning to world map - create a map with the editor and save it, then switch to editing the mission, add some spawns and actors");
						obj_scene.state = e_misc_states.done;
						//state = e_player_states.idle;
					}
				
					#endregion
				}
			
				//CHANGE PLAYER'S STATE																			
				state = e_player_states.talking;
			}
		
			#endregion
		
		}
	
		#endregion
	
	}else{ //Wrapped states within "else" statements to prevent keyboard checks being read in subsequent states unintentionally

		if (state == e_player_states.world_menu){
	
			#region	WORLD MENU																			
	
			//Change highlighted option
			if (keyboard_check_pressed(vk_up) || keyboard_check_pressed(vk_down) )
			highlighted_option = scr_change_option(highlighted_option, 0, e_world_actions.last - 1, 1); 
	
			//Change back to idle
			if (keyboard_check_pressed(vk_backspace)){
				state = e_player_states.idle;
			}
	
			//Choose an action
			if (keyboard_check_pressed(vk_enter) ){
				if (highlighted_option == e_world_actions.army){
					state = e_player_states.army_screen;
					instance_create_layer(0, 0, layer, obj_army_screen);	
				}
				
				//GO TO THE SHOP 
				var story_state = global.ds_values[| e_values_to_track.story_state];					
				var column_to_check = (path_point.path_point) * e_path_point_setup.last;				
				var map_type = real ( global.story_points[# column_to_check + 1, story_state] ); 
				
				if (highlighted_option == e_world_actions.shop && map_type == e_map_types.shop){
					state = e_player_states.shop;
					instance_create_layer(0, 0, layer, obj_shop);
				}
				
				if (highlighted_option == e_world_actions.save) scr_save_game(global.current_save_file);
				if (highlighted_option == e_world_actions.load){	
					state = e_player_states.init;
					global.main_state = e_main_states.load_game;
				}
			}
	
			#endregion
	
		}
	
	}

}
