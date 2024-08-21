//Display Units in Army at the top, information about the unit can go at the bottom?
	
//Draw a background
draw_sprite(spr_army_screen, 0, 0, 0);
									
if (state == e_army_states.choose_unit || state == e_army_states.change_class){  
	
	#region CHOOSE UNIT	/ CHANGE CLASS										
	
	/*
	- Radial Selection for units

	- Have a list of units
	- Divide 360 by number of units - this is the number of degrees between each
	- left/right will scroll between the units
	- the "selected_unit" will be the bottom most unit, and the placement 
	 of the others will be based on these starting coordinates
	
	right being 0º, up being 90º, left being 180º and down being 270º.
	        90
		180    0
		   270
	*/
	
	draw_set_colour(c_red);
	
	var x1 = ellipse_draw_x - ellipse_width; var x2 = ellipse_draw_x + ellipse_width;		
	var y1 = ellipse_draw_y - ellipse_height; var y2 = ellipse_draw_y + ellipse_height;		
	
	draw_ellipse(x1, y1, x2, y2, true);
	
	if (state == e_army_states.choose_unit) draw_list = army_list;			
	else draw_list = list_of_classes;											
	
	scr_ellipse_sort_draw_order(draw_list, units_to_draw);	
	
	while ds_priority_size(units_to_draw) > 0{
		var list = ds_priority_delete_min(units_to_draw);
		
		scr_army_screen_draw_unit(list[| 0], list[| 1], list[| 2], 
		list[| 3], list[| 4], list[| 5], list[| 6], list[| 7], 1, c_white);
		
		if (state == e_army_states.choose_unit) var sel_opt = draw_list[| selected_unit];
		else sel_opt = selected_option;													
		if (list[| 0] == sel_opt) draw_sprite_ext(spr_army_selection, 0, list[| 1], list[| 2],	
																	 list[| 3], list[| 3], 0, c_white, 1);
		
		ds_list_destroy(list);
	}

	#endregion
	
}

//Made a region specifically to draw the selected unit, rather than do it 3 times in 3 different states
if (state == e_army_states.display_options || state == e_army_states.change_equipment || state == e_army_states.change_class){	
	
	#region Draw selected unit																								
				
	draw_scale = 3;
	draw_x = display_get_gui_width() / 2;
	draw_y = sprite_get_height(spr_iso_actor_idle_e) * draw_scale;
	
	scr_army_screen_draw_unit(army_list[| selected_unit], draw_x, draw_y, draw_scale, e_facing.east, true, e_battle_menu.move, 0, 1, c_white);		
	
	#endregion
	
}

if (state == e_army_states.display_options){
	
	#region DISPLAY OPTIONS			
	
	//Draw options
	for (var i = e_army_states.change_class; i < e_army_states.last; i ++){
		var text = a_option_text[i];
		var start_y = display_get_gui_height() - (24 * 4);
		
		if (global.character_stats[# e_stats.is_special_character, army_list[| selected_unit] ] == "0") var can_be_sacked = true; 
		else can_be_sacked = false;
		
		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		
		if (i == e_army_states.fire_unit && can_be_sacked || i != e_army_states.fire_unit){									
			draw_set_colour(c_gray);
			if (i == selected_option) draw_set_colour(c_white);
		}else{
			draw_set_colour(c_black);
			if (i == selected_option) draw_set_colour(c_dkgray);
		}

		draw_set_font(fnt_options);
		
		draw_text(20, start_y + ((i - 2) * 24), text);
	}
	
	#endregion
	
}

#region DISPLAY STATS

var unit = army_list[| selected_unit];

for (var i = 0; i < ds_list_size(stats_to_display); i ++){
	var stat_value = global.character_stats[# stats_to_display[| i], unit];
	
	//We need some extra code to display the class of the unit
	if (stats_to_display[| i] == e_stats.class){
		var class = global.character_stats[# e_stats.class, unit];
		var stat_value = global.character_stats[# e_stats.name, class];
	}
	
	var stat_text = stat_text_grid[# 0, stats_to_display[| i] ];
	
	draw_set_halign(fa_right);
	draw_set_valign(fa_top);
	draw_set_font(fnt_editor);
	draw_set_colour(c_orange);
	
	draw_text(display_get_gui_width() - 100, i * 14, stat_text + ": ");
	
	draw_set_halign(fa_left);
	draw_set_colour(c_black);
	
	if (state == e_army_states.change_class){
	
		#region CHECK TO SEE IF THE UNIT STATS MEET THE CLASS STAT REQUIREMENT 
	
		var current_stat = real ( stats_to_display[| i] );
		
		if (current_stat >= e_stats.strength && current_stat <= e_stats.agility){
		
			var class = selected_option;
			var class_req = real ( global.class_req[# current_stat, class] );
			if (stat_value < class_req) draw_set_colour(c_red);
			
		}
	
		#endregion
	
	}
	
	draw_text(display_get_gui_width() - 100, i * 14, stat_value);
}

#endregion

if (state == e_army_states.display_options || state == e_army_states.change_equipment){
	
	#region DISPLAY GEAR																								
	item_width = sprite_get_width(spr_items);
	item_height = sprite_get_height(spr_items);
	
	start_x = ( display_get_gui_width() / 2 ) - ( (item_width * 4.5 ) / 2 );
	start_y = (sprite_get_height(spr_iso_actor_idle_e) * 3) + (item_height * 2);
	
	var counter = 0;
	
	for (var i = e_stats.left_hand; i <= e_stats.item_2; i ++){
		var equipped_item = real(global.character_stats[# i, army_list[| selected_unit] ]);
		
		draw_x = start_x + (counter * item_width);
		draw_y = start_y;
		
		//Draw BG
		draw_sprite(spr_item_bg, 0, draw_x, draw_y);
		
		//Draw Item
		draw_sprite(spr_items, equipped_item, draw_x, draw_y);
		draw_set_colour(c_black);
		//draw_text(draw_x, draw_y, string(equipped_item) ); //comment this out to get rid of the numbers drawn over the items
		
		if (selected_option == i){														
			//Draw lime rectangle around selected slot
			draw_set_alpha(0.5);
			draw_set_colour(c_lime);
			draw_rectangle(draw_x - (item_width/2), draw_y - (item_height/2), draw_x + (item_width/2), draw_y + (item_height/2), false);
			draw_set_alpha(1);	
		}
		
		counter ++;
	}
	
	#endregion
	
	#region DISPLAY GEAR LIST														
	
	if (state == e_army_states.change_equipment && show_gear_list){
		start_x = ( display_get_gui_width() / 2 ) - ( (item_width * 4.5 ) / 2 );
		start_y = (sprite_get_height(spr_iso_actor_idle_e) * 3) + (item_height * 4);
		
		for (var i = 0; i < ds_list_size(gear_list); i ++ ){
			draw_x = start_x + (i * item_width);
			draw_y = start_y;
		
			//Draw BG
			draw_sprite(spr_item_bg, 0, draw_x, draw_y);
		
			//Draw Item
			draw_sprite(spr_items, gear_list[| i], draw_x, draw_y);
			
			//Draw lime rectangle around selected slot
			if (selected_option == i){									
				draw_set_alpha(0.5);
				draw_set_colour(c_lime);
				draw_rectangle(draw_x - (item_width/2), draw_y - (item_height/2), draw_x + (item_width/2), draw_y + (item_height/2), false);
				draw_set_alpha(1);
			}
		}
	}
	
	#endregion
	
}