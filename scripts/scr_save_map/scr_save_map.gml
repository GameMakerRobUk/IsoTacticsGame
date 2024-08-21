/// @function scr_save_map(map_number, grid to copy from)
/// @description Save the map!
/// @param {real} map_number - the number of the map we're saving (this is the entry in the battle map list)
/// @param {real} grid_to_copy_from - what's the name of the grid that we just made the map in?
function scr_save_map(map_number, grid_to_copy_from) {

	/*
		We'll make a temporary grid, turn the lists into a string for every cell and save that string into the cell of the temp grid 
		- then we convert the temp grid into a string and save that string to battle_map_list. We can then destroy the temp grid
	*/

	var grid_width = ds_grid_width(grid_to_copy_from);
	var grid_height = ds_grid_height(grid_to_copy_from);

	var grid_to_write_to = ds_grid_create(grid_width, grid_height);
	
	//Convert the data in the lists into a string (we have to save each list in turn)
	for (var yy = 0; yy < grid_height; yy ++){
		for (var xx = 0; xx < grid_width; xx ++){
		
			var list = grid_to_copy_from[# xx, yy]; //Grab the list pointer
			var list_str = ds_list_write(list); //convert the data stored in that list into a string
			//show_debug_message(list_str)
			//Add string to grid_to_write_to
			grid_to_write_to[# xx, yy] = list_str; //copy the string to the proper cell coordinates in the grid we're going to save with
		}
	}

	//convert the grid into a string and save it into grid_and_lists_string
	var grid_and_lists_string = ds_grid_write(grid_to_write_to);
	//show_debug_message(grid_and_lists_string)
	show_debug_message("Map " + string(map_number) + " saved");

	ds_grid_destroy(grid_to_write_to);

	return grid_and_lists_string;




}
