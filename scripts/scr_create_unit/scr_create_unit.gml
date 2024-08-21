/// @function scr_create_unit(unit_class, unit_level, grid_to_save_to)
/// @description Add a unit to a grid (eg a shop or enemy army grid for battle)
/// @param {real} unit_class - the class of the new unit 1/2/3/e_characters.fighter etc
/// @param {real} unit_level - the level of the new unit - this will affect its stats
/// @param {real} character_grid - the grid to add the unit to
function scr_create_unit(class, level, grid) {

	var entry = -1; //the entry in the grid to save the stats

	//Find the next available spot in the grid
	for (var yy = 0; yy < ds_grid_height(grid); yy ++){
		if (grid[# e_stats.name, yy] == ""){
			var entry = yy; break;
		}
	}

	if (entry == -1){
		//We didn't find a spare slot in the grid, so resize the grid
		entry = ds_grid_height(grid);
		ds_grid_resize(grid, ds_grid_width(grid), ds_grid_height(grid) + 1);
	}

	for (var stats = 0; stats < e_stats.last; stats ++){
		grid[# stats, entry] = global.character_stats[# stats, class];
			
		//Level up the stats - we'll change this calculation in the future
		if (stats >= e_stats.hp_max && stats <= e_stats.mp_current) grid[# stats, entry] = ( real(global.character_stats[# stats, class]) * level );
		if (stats == e_stats.level) grid[# stats, entry] = level;
		if (stats >= e_stats.strength && stats <= e_stats.accuracy) grid[# stats, entry] = ( real(global.character_stats[# stats, class]) * level );
	
	}

	return(entry);

}
