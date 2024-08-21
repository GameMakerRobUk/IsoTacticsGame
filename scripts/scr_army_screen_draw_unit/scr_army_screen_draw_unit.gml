/// @function scr_army_screen_draw_unit(unit, draw_x , draw_y, draw_scale, facing, draw_name, action, image_index, team, col)		
/// @description draw a unit and its name
/// @param {real} unit - which unit are we trying to draw (Class/Special Character)
/// @param {real} draw_x - x coordiante to draw
/// @param {real} draw_y - y coordiante to draw
/// @param {real} draw_scale - how much to scale the sprite
/// @param {real} facing - which facing do we want to draw									
/// @param {boolean} draw_name - draw name (true) or not? (false)		
/// @param {real} action - e_battle_menu.move etc - so that we can draw different states/animations					
/// @param {real} index - the image_index to draw	
/// @param {real} team - which team is the unit on?	
/// @param {real} col - the colour to draw	

function scr_army_screen_draw_unit(unit, draw_x, draw_y, draw_scale, facing, draw_name, action, index, team, col) {																						

	if (team == 1) var sprite_grid = global.char_sprite_grids[| unit];
	else var sprite_grid = global.char_sprite_grids_enemy[| unit];

	//IF IT'S NOT A SPECIAL CHARACTER, USE THE CLASS GRID FOR SPRITES
	if (global.character_stats[# e_stats.is_special_character, unit] == "0"){	
		var class = global.character_stats[# e_stats.class, unit];
		
		//Is it a player or enemy unit?
		if (team == 1) sprite_grid = global.char_sprite_grids[| class];
		else var sprite_grid = global.char_sprite_grids_enemy[| class];
	}
												
	var sprite = sprite_grid[# action, facing];	

	var name = global.character_stats[# e_stats.name, unit];
	
	draw_sprite_ext(sprite, index, draw_x, draw_y, draw_scale, draw_scale, 0, col, 1);

	if (draw_name){																	
		draw_set_halign(fa_center);
		draw_set_valign(fa_bottom);
		draw_set_colour(c_red);
		draw_set_font(fnt_editor);
		
		draw_text(draw_x, draw_y + ( (sprite_get_height(spr_army_selection) - sprite_get_yoffset(spr_army_selection) ) * draw_scale ), name);
	}


}
