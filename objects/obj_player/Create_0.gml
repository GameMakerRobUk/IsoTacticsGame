enum e_player_states{
	init,
	rewards,					
	idle,
	walking,
	talking,													
	army_screen,												
	world_menu,		
	shop,				
}

path_point = noone; //Which path point are we on, if any
//prev_path_point = noone;
selected_option = 0;			
target_path_point = path_point; 
state = e_player_states.init;

//Grab the sprite grid for Butz
char_grid = global.char_sprite_grids[| e_characters.butz];
show_debug_message("e_characters.butz: " + string(e_characters.butz) );

for (var yy = 0; yy < ds_grid_height(char_grid); yy ++){
	var str = "";
	for (var xx = 0; xx < ds_grid_width(char_grid); xx ++){
		str += string(char_grid[# xx, yy]) + " | ";
	}	
	show_debug_message(str);
}

sprite_index = char_grid[# e_actor_sprites.idle, e_facing.east];
image_speed = ACTOR_ANIMATION_SPEED;