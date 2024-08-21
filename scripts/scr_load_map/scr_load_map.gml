/// @function scr_load_map(map_number, grid_to_copy_to, list_of_battle_maps)																		
/// @description load the map!
/// @param {real} map_number - the number of the map we're loading (this is the entry in the battle map list)
/// @param {real} grid_to_copy_to - what's the name of the grid that we're going to copy data to
/// @param {real} list_of_battle_maps - what's the name of the list that holds all our battle map strings
function scr_load_map(map_number, grid_to_copy_to, list_of_battle_maps) {

	/*
		Create a temporary grid, convert the saved string from battle_map_list into the temp grid. Each cell of the temp grid will
		hold a string that used to be the data in a list. 
		We just need to convert those strings back into lists and we loaded our map back (ds_terrain_data will now contain that data)
	*/

	var grid_to_copy_from = ds_grid_create(1, 1); //the width/height doesn't matter at the moment as ds_grid_read will resize it anyway

	if (list_of_battle_maps[| map_number] != undefined) && (list_of_battle_maps[| map_number] != ""){
		ds_grid_read(grid_to_copy_from, list_of_battle_maps[| map_number]);

		//Destroy all the lists in ds_terrain and then resize it - this allows for differently-sized maps
		for (var yy = 0; yy < ds_grid_height(grid_to_copy_to); yy ++){
			for (var xx = 0; xx < ds_grid_width(grid_to_copy_to); xx ++){
				var list = grid_to_copy_to[# xx, yy];
				ds_list_destroy(list);
			}
		}
	
		//Grab the width/height of the temporary grid
		var grid_width = ds_grid_width(grid_to_copy_from);
		var grid_height = ds_grid_height(grid_to_copy_from);
	
		//Resize ds_terrain_data
		ds_grid_resize(grid_to_copy_to, grid_width, grid_height);
	
		unique_conversation_index = 0; //This will hold the highest-valued conversation index - we need this to be able to easily delete/add new characters that may or may not want to talk		

		//Convert the strings into lists holding data and store that list in the relevant cell of grid_to_copy_to
		for (var yy = 0; yy < grid_height; yy ++){
			for (var xx = 0; xx < grid_width; xx ++){
				var list = ds_list_create();
				var list_str = grid_to_copy_from[# xx, yy]; //grab the string from the cell
				ds_list_read(list, list_str); //convert the string back into our list data
			
				grid_to_copy_to[# xx, yy] = list;
				//show_debug_message(list)
			
				//Check for a higher-value conversation index																																		
				var con_in = list[| e_tile_data.conversation_index];
				if (con_in != undefined) && con_in > unique_conversation_index unique_conversation_index = con_in;
			}
		}
	
		//If spawn tiles are already placed on this map, we need to increase unique_conversation_index by 1, otherwise we can leave it at 0
		if (unique_conversation_index != 0) unique_conversation_index ++;															

		show_debug_message("Map " + string(map_number) + " Loaded");
		ds_grid_destroy(grid_to_copy_from);
	
		return grid_to_copy_to;

	}else{
		show_debug_message("Map failed to load");
		return grid_to_copy_from;
	}


}
