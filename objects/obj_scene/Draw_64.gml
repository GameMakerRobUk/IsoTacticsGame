#region DRAW CONVERSATION											
					
if (state == e_misc_states.conversation){						

	draw_set_font(fnt_conversation);
	var font_size = font_get_size(fnt_conversation);

	draw_set_halign(fa_center);
	draw_set_valign(fa_top);

	var sep = font_size * 1.4;
	var w = 300;
	t_height = string_height_ext(text, sep, w) + 20;

	var xx = display_get_gui_width() / 2;
	var yy = display_get_gui_height() - t_height;

	//Name
	draw_set_font(fnt_names);
	
	#region DRAW BLACK BACKGROUND							
	
	var x1 = xx - (string_width(unit_name) / 2);
	var y1 = yy - (font_size + 20);
	var x2 = xx + (string_width(unit_name) / 2);
	var y2 = y1 + string_height(unit_name);
	
	draw_set_colour(c_black);
	draw_rectangle(x1, y1, x2, y2, false);
	
	#endregion
	
	draw_set_colour(c_red);
	draw_text(xx, yy - (font_size + 20), unit_name);

	//Text
	draw_set_font(fnt_conversation);
	
	#region DRAW BLACK BACKGROUND							
	
	var x1 = xx - (string_width_ext(text, sep, w) / 2);
	var y1 = yy;
	var x2 = xx + (string_width_ext(text, sep, w) / 2);
	var y2 = yy + string_height_ext(text, sep, w);
	
	draw_set_colour(c_black);
	draw_rectangle(x1, y1, x2, y2, false);
	
	#endregion
	
	draw_set_colour(c_white);
	draw_text_ext(xx, yy, text, sep, w);

}

#endregion

if (state == e_misc_states.choose_units || state == e_misc_states.display_reserve){							
	
	#region CHOOSE UNITS																					
	
	//DRAW BACKGROUND
	draw_sprite(spr_army_screen, 0, 0, 0);
	
	var scale = 3;
	var tile_width = sprite_get_width(spr_iso_width_height) * scale;
	var tile_height = sprite_get_height(spr_iso_width_height) * scale;
	
	start_x = (display_get_gui_width() / 2) - (tile_width / 2);
	start_y = (display_get_gui_height() / 2) - ( (tile_height ));
	
	#region Draw Spawn Tiles and units
	
	var counter = 0;
	
	for (var yy = 0; yy < 2; yy ++){
		for (var xx = 0; xx < 4; xx ++){
			
			var draw_x = start_x + (xx - yy) * (tile_width / 2);						
			var draw_y = start_y + (xx + yy) * (tile_height / 2);
			
			draw_sprite_ext(spr_iso_spawn_tiles, 0, draw_x, draw_y, scale, scale, 0, c_white, 1);
			var list = spawn_tile_list[| counter];														 
			var unit = list[| e_tile_data.unit];	
			//draw_text(draw_x, draw_y-60, string(unit) ); //debug/testing
			
			if (unit >= e_characters.fighter) scr_army_screen_draw_unit(unit, draw_x, draw_y, scale, e_facing.south, false, e_battle_menu.move, obj_player.image_index, 1, c_white);
			
			#region Show which character is about to be moved with another									
			
			if (state == e_misc_states.choose_units && prev_selected_option > -1 && counter == prev_selected_option){
				draw_sprite_ext(spr_iso_select, 1, draw_x, draw_y, scale, scale, 0, c_white, 1);
			}
			
			#endregion
			
			#region Display the selection cursor (can't use selected_option for both states)				
			
			if (state == e_misc_states.choose_units && selected_option == counter) ||
			   (state == e_misc_states.display_reserve && prev_selected_option == counter)
			   draw_sprite_ext(spr_iso_select, 0, draw_x, draw_y, scale, scale, 0, c_white, 1); 
			
			#endregion
			
			counter ++;
		}
	}
	
	#endregion
	
	#endregion
	
	if (state == e_misc_states.display_reserve){
	
		#region DISPLAY RESERVE UNITS							
		
		draw_set_colour(c_red);
	
		var x1 = ellipse_draw_x - ellipse_width; var x2 = ellipse_draw_x + ellipse_width;		
		var y1 = ellipse_draw_y - ellipse_height; var y2 = ellipse_draw_y + ellipse_height;		
	
		draw_ellipse(x1, y1, x2, y2, true);										
	
		scr_ellipse_sort_draw_order(reserve_list, draw_queue);	
	
		while ds_priority_size(draw_queue) > 0{
			var list = ds_priority_delete_min(draw_queue);
		
			scr_army_screen_draw_unit(list[| 0], list[| 1], list[| 2], 
			list[| 3], list[| 4], list[| 5], list[| 6], obj_player.image_index, 1, c_white);
		
			var sel_opt = reserve_list[| selected_option];
												
			if (list[| 0] == sel_opt) draw_sprite_ext(spr_army_selection, 0, list[| 1], list[| 2],	
																		 list[| 3], list[| 3], 0, c_white, 1);
		
			ds_list_destroy(list);
		}

		#endregion
	
	}
	
}

#region DRAW BATTLE MENU									

if (current_action == e_battle_menu.awaiting_action && battle_state == e_battle.actor_taking_turn){
	
	#region DRAW UNIT GUI					
	
	draw_set_font(fnt_options);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_colour(c_white);
	
	var h = display_get_gui_height();
	
	if (current_actor != noone){
		var name = current_actor.a_stats[e_stats.name];
		var class = global.character_stats[# e_stats.name, current_actor.a_stats[e_stats.class] ];
		var hp = string( current_actor.a_stats[e_stats.hp_current] );
		var hp_max = string( current_actor.a_stats[e_stats.hp_max] );
		var mp = string( current_actor.a_stats[e_stats.mp_current] );
		var mp_max = string( current_actor.a_stats[e_stats.mp_max] );
		
		draw_text(20, h - 60, class);
		draw_text(20, h - 30, name);
		draw_text(300, h - 60, "HP");
		draw_text(300, h - 30, hp + " / " + hp_max);
		draw_text(500, h - 60, "MP");
		draw_text(500, h - 30, mp + " / " + mp_max);
	}
	
	#endregion

	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);

	draw_set_colour(c_white);
	draw_set_font(fnt_conversation);
	
	var spr_w = sprite_get_width(spr_battle_menu_button);
	var spr_h = sprite_get_height(spr_battle_menu_button);

	for (var i = e_battle_menu.move; i <= e_battle_menu.item; i ++){
		draw_x = spr_w / 2;
		draw_y = spr_h + ( (i - 1) * ( spr_h * 1.2 ) );
		
		//Highlight the selected option
		if (selected_option == i) var index = 1; else index = 0;
	
		draw_sprite(spr_battle_menu_button, index, draw_x, draw_y);
		draw_text(draw_x, draw_y, a_battle_menu_text[i]);
	}

	#region DRAW SECONDARY MENU OPTIONS														
		
	var list = battle_menu_lists[| selected_option];
		
	for (var i = 0; i < ds_list_size(list); i ++){
		draw_x = spr_w * 1.5;
		draw_y = spr_h + ( i * ( spr_h * 1.2 ) );
		var item = list[| i];
			
		if (item != undefined){
			if (secondary_option == i) index = 1; else index = 0;
			
			text = global.items[# item, e_item_stats.name];
			
			draw_sprite(spr_battle_menu_button, index, draw_x, draw_y);
			draw_set_font(fnt_editor);
			draw_text(draw_x, draw_y, text);
		}
	}
		
	#endregion
	
}

#endregion

#region DEBUG [commented out]
/*

if (current_actor != noone){
	var gw = display_get_gui_width();
	draw_set_halign(fa_right);
	draw_set_valign(fa_top);
	draw_set_colour(c_white);
	draw_set_font(fnt_editor);
	
	draw_text(gw, 0, "state: " + string(current_actor.state) );
	draw_text(gw, 20, "sprite: " + string(current_actor.sprite_index) );
	draw_text(gw, 40, "sprite (from grid) : " + string(current_actor.sprite_grid[# 0, current_actor.state] ) );
	draw_text(gw, 60, "frames: " + string(sprite_get_number(current_actor.sprite_index) ) );
	draw_text(gw, 80, "image index: " + string(current_actor.image_index) );
	draw_text(gw, 100, "actor index: " + string(current_actor.actor_id) );
	
	for (var yy = 0; yy < 4; yy ++){
	   for (var xx = 0; xx < e_actor_sprites.last; xx ++){
		  var frames = sprite_get_number(current_actor.sprite_grid[# current_actor.state, 0]);
		  draw_text( (gw - 120) + (xx * 20), 120 + (yy * 20), string(frames) );   
	   }
	}
	
	draw_sprite(current_actor.sprite_index, 0, gw - 80, 300);
}

*/

#endregion