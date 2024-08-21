draw_self();

if (state == e_player_states.idle && path_point != noone){
	
	#region DRAW VALID PATHS
	
	for (var i = 0; i < ds_list_size(path_point.connects_to); i ++){
		
		connecting_path_point = path_point.connects_to[| i];
		connecting_id = path_array[connecting_path_point];
		
		//Draw Line
		draw_set_colour(c_red);
		draw_line(path_point.x, path_point.y, connecting_id.x, connecting_id.y);
	}
	
	#endregion

}

if (state == e_player_states.world_menu){																				

	#region DRAW ACTIONS 
	
	start_y = y - 80;
	
	for (var i = 0; i < e_world_actions.last; i ++){
		
		var story_state = global.ds_values[| e_values_to_track.story_state];					
		var column_to_check = (path_point.path_point) * e_path_point_setup.last;				
		var map_type = real ( global.story_points[# column_to_check + 1, story_state] ); 
		
		var text = global.world_action_text[i];
		
		//Set the colour to gray if there's no shop in this area, otherwise set to white (and white for every other action too)
		if (map_type == e_map_types.shop && i == e_world_actions.shop) || (i != e_world_actions.shop){
			draw_set_colour(c_gray);
			
			//check for highlighted action and make it white																
			if (i == highlighted_option) draw_set_colour(c_white);
		}
		else{
			draw_set_colour(c_black);
			if (i == highlighted_option) draw_set_colour(c_dkgray); 
		}
		
		var draw_x = x;
		var draw_y = start_y + (i * 14);
		
		draw_set_font(fnt_editor);
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		
		draw_text(draw_x, draw_y, text);
	}
	
	#endregion
	
}
