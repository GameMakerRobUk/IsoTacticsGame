/// @function scr_center_on_speaker(speaker, terrain grid)
/// @description Center the map on whoever is speaking
/// @param {real} speaker - the unique_conversation_index of the speaker (the digit(s) at the start of the text)
/// @param {real} terrain_grid - which grid is holding the tile lists that we're drawing the map with
function scr_center_on_speaker(speaker, grid) {
	
	var unit = noone;

	//Find the location of the speaker first
	for (var yy = 0; yy < ds_grid_height(grid); yy ++){
		for (var xx = 0; xx < ds_grid_width(grid); xx ++){
		
			var list = grid[# xx, yy];
			var con_in = list[| e_tile_data.conversation_index];
		
			if (con_in == speaker){
				//Found the correct conversation index		
				draw_height = list[| e_tile_data.height];
				unit = list[| e_tile_data.unit];
			
				//show_debug_message("unit scr_center_on_speaker line 21: " + string(unit));
			
				cx = (xx - yy) * (iso_width / 2);						
				cy = (xx + yy) * (iso_height / 2) - (draw_height * (iso_height / 2 ) );
			
				camera_set_view_pos(view_camera[0], cx - ( camera_get_view_width(view_camera[0]) / 2 ), cy - ( camera_get_view_height(view_camera[0]) / 2 ) );	
			
				//show_debug_message("FOUND SPEAKER: " + string(xx) + "/" + string(yy));
			
				break;
			}
		}
	}

	return(unit);

}
