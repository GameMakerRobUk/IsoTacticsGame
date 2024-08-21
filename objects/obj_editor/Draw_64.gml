#region DRAW new_index + relevant sprite																

if (editing_state == e_editing_states.map){														
	
	var draw_x = display_get_gui_width() / 2;
	var draw_y = display_get_gui_height() - 32;
	var scale = 2;

	var spr = global.cell_sprites[current_part];										

	draw_sprite_ext(spr, new_index, draw_x, draw_y, scale, scale, 0, c_white, 1); 
	
}

#endregion

#region DRAW MISSION EDITOR GUI																									

if (editing_state == e_editing_states.mission){
	
	draw_scale = 2;

	#region DRAW SPAWN POINT ICONS

	var spr_w = sprite_get_width(spr_iso_spawn_tiles) * draw_scale;
	var spr_h = sprite_get_height(spr_iso_spawn_tiles) * draw_scale;
	var start_x = spr_w;
	var start_y = display_get_gui_height() - spr_h;
	
	for (var team = 0; team < sprite_get_number(spr_iso_spawn_tiles); team ++){
		var draw_x = start_x + (team * spr_w);
		var draw_y = start_y;
		var mx = device_mouse_x_to_gui(0); //mouse x based on the GUI layer
		var my = device_mouse_y_to_gui(0); //mouse y based on GUI layer
		
		if (abs(mx - draw_x) <= ( spr_w / 2) && abs (my - draw_y) <= (spr_h / 2) ){
			var col = c_ltgray;
			if (mouse_check_button_pressed(mb_left)){
				mouse_sprite = spr_iso_spawn_tiles;
				mouse_index = team;
			}
		}else col = c_white;
		
		draw_sprite_ext(spr_iso_spawn_tiles, team, draw_x, draw_y, draw_scale, draw_scale, 0, col, 1);
	}

	#endregion
	
	#region DRAW CHARACTER
	
	var spr_w = sprite_get_width(spr_iso_actor_idle_w) * draw_scale;																		
	var spr_h = sprite_get_height(spr_iso_actor_idle_w) * draw_scale;																	
	
	draw_x = sprite_get_width(spr_iso_spawn_tiles) * 6;
	draw_y = display_get_gui_height() - sprite_get_height(spr_iso_actor_idle_w);														
	
	var mx = device_mouse_x_to_gui(0); //mouse x based on the GUI layer
	var my = device_mouse_y_to_gui(0); //mouse y based on GUI layer
	
	if (abs(mx - draw_x) <= (spr_w / 2) && abs(my - draw_y) <= (spr_h / 2) ){
		col = c_ltgray;	
		if (mouse_check_button_pressed(mb_left)){
			mouse_sprite = spr_iso_actor_idle_w;																						
			mouse_index = e_facing.south;
		}
	}else col = c_white;
	
	draw_sprite_ext(spr_iso_actor_idle_w, e_facing.south, draw_x, draw_y, draw_scale, draw_scale, 0, col, 1);							
	
	#endregion
	
	#region DRAW AI_CONTROLLED / MUST_SURVIVE / KILL_TO_WIN																		
	
	var list = ds_terrain_data[# grid_x, grid_y];
	
	if (list != undefined && list[| e_tile_data.unit] >= e_characters.fighter && list[| e_tile_data.unit] != undefined){		
		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		draw_text(0, 60, "Ai Controlled: " + string(list[| e_tile_data.is_ai_controlled]) );
		draw_text(0, 80, "Must Survive: " + string(list[| e_tile_data.must_survive_this_battle]) );
		draw_text(0, 100, "Kill to win: " + string(list[| e_tile_data.kill_this_unit_to_win]) );
	}
	
	#endregion
	
	#region TESTING - unique_conversation_index	[commented out]																		
	/*
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	
	var draw_x = display_get_gui_width() / 2;
	var draw_y = 40;
	
	draw_text(draw_x, draw_y, "unique_conversation_index: " + string(unique_conversation_index) );
	draw_text(draw_x, draw_y + 20, "map index: " + string(current_map_number) );
	draw_text(draw_x, draw_y + 40, "mouse_index: " + string(mouse_index) );
	*/
	#endregion
	
}

#endregion