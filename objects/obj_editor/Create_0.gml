#region SETUP TILE ENUMERATOR																									

enum e_tile_data{
	floor_index,
	decoration_index,
	height,
	spawn_tile,						//-1 for no spawn, 0 is Player 1 is Enemy - based on iamge index of spr_iso_spawn_tiles
	conversation_index,			//Each spawn tile will have a unique conversation index PER MAP. This is how we will know which character is talking (and allows us to make regular units talk also)
	unit,								//Either a class or a special character
	unit_facing,					//West/North/East/South 
	is_ai_controlled,				//True/false
	must_survive_this_battle,	//True/false If true and this unit dies, game is over
	kill_this_unit_to_win,		//True/false By killing this unit, the battle is won by the player
	last,
}

#endregion

#region SETUP A GRID																											

hcells = 10;
vcells = 10;

ds_terrain_data = ds_grid_create(hcells, vcells);

for (var yy = 0; yy < vcells; yy ++){
	for (var xx = 0; xx < hcells; xx ++){
		
		//Create a list for EVERY cell (100 lists)
		var list = ds_list_create();											                      
		
		//Set initial cell data for each list
		for (var i = 0; i < e_tile_data.last; i ++){
			//set floor_index to 1 and everything else to 0
			if (i == e_tile_data.floor_index) list[| i] = 1; else list[| i] = 0;
			if (i >= e_tile_data.spawn_tile) list[| i] = -1;																	    
		}
		
		//Save the list pointer in the grid cell
		ds_terrain_data[# xx, yy] = list;                                                        
		
	}
}

#endregion

#region EXTRA VARIABLES																											

grid_x = 0; //Where is the mouse on the grid?
grid_y = 0; //Where is the mouse on the grid?
new_index = 1; //We'll use this variable to change the cell indexes
iso_width = sprite_get_width(spr_iso_width_height);
iso_height = sprite_get_height(spr_iso_width_height);

//Center the camera on the map
cx = (iso_width / 2) - (camera_get_view_width(view_camera[0]) / 2);									   
cy = -(camera_get_view_height(view_camera[0]) / 4);														
camera_set_view_pos(view_camera[0], cx, cy);	

//Moar editing variables																								
current_height = 0; //What height should the tile be set to?
max_height = 12; //Maximum height of a tile

current_part = e_tile_data.floor_index; //Which part of the tile are we editing? Floor/Decoration?		 
current_sprite = global.cell_sprites[current_part]; //which sprite are we using to edit at the moment?	  
current_map_number = 0; //Which map "number" are we editing?																				
battle_map_list = ds_list_create(); //This list will hold the strings that convert into a grid with each cell also converting into a list   

display_all_heights = true; //Display all of the heights, or not (not will mean viewable heights are limited to current_height)
total_maps = 0; //How many maps have been saved?

#region MISSION EDITOR																																

mouse_sprite = -1; //Is the mouse holding a sprite or not
mouse_index = 0; //Index of the sprite that the mouse is to display
unique_conversation_index = 0; //This number increases every time a spawn tile is put down. The number does not decrease if a spawn tile is deleted

#endregion

#endregion

#region EDITING STATES																											

enum e_editing_states{
	map,
	mission,
}

editing_state = e_editing_states.map;//e_editing_states.mission;

#endregion

//Load existing maps that were saved previously
scr_load_game_data();
