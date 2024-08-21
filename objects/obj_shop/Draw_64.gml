//draw background
draw_sprite(spr_shop_bg, 0, 0, 0);
margin = 20;										

#region DISPLAY STATE									

draw_set_halign(fa_center);
draw_set_valign(fa_top);
draw_set_colour(c_white);
draw_set_font(fnt_conversation);

draw_text(display_get_gui_width() / 2, margin, heading_text[state] );

#endregion

if (state == e_shop_states.display_buy_sell || state == e_shop_states.display_items_units){
	
	#region DISPLAY OPTIONS																	
	
	draw_set_font(fnt_conversation);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_colour(c_white);
	
	if (state == e_shop_states.display_items_units) var i_start = e_shop_states.items; else i_start = e_shop_states.buy;		
	
	var count = 1;
	
	for (var i = i_start; i <= (i_start + 1); i ++){														
		draw_set_colour(c_gray);
		if (selected_option == i) draw_set_colour(c_white);
		draw_text(margin * 2, count * 30, a_text[i]);											
		
		count ++;																					
	}
	
	#endregion
	
}

if (state == e_shop_states.units){
				
	#region UNITS																					
	
	var draw_scale = 3;
	var unit_width = sprite_get_width(spr_iso_actor_idle_s) * draw_scale;
	var unit_height = sprite_get_height(spr_iso_actor_idle_s) * draw_scale;
	var start_x = unit_width;
	//var start_y = unit_height;
	var start_y = unit_height * 1.5;													
	
	for (var i = 0; i < ds_list_size(list_of_units); i ++){
		draw_x = start_x + (unit_width * i);
		draw_y = start_y;
		var unit = list_of_units[| i];
		
		scr_army_screen_draw_unit(unit, draw_x, draw_y, draw_scale, e_facing.east, true, e_battle_menu.move, 0, 1, c_white);		
		
		//Show if selected
		if (selected_option == i){
			draw_sprite_ext(spr_army_selection, 0, draw_x, draw_y, draw_scale, draw_scale, 0, c_white, 1);
		}
		
		#region Show cost of unit														
		
		
		var cost_of_unit = string ( global.character_stats[# e_stats.cost_to_buy, unit] );
		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		draw_set_colour(c_white);
		draw_set_font(fnt_editor);
		
		draw_text(draw_x + 10, 60, cost_of_unit + "g");
		
		#endregion
	}
	
	#endregion
	
}

if (state == e_shop_states.sell || state == e_shop_states.items){						
	
	//We're using this region to draw items, whether they're being sold or bought
	
	#region SELL																							
	
	start_x = 32 + margin;																	
	start_y = 64 + margin;																		
	var scale = 2;
	var item_width = sprite_get_width(spr_items) * scale;
	var item_height = sprite_get_height(spr_items) * scale;
	
	if (state == e_shop_states.sell) var list = list_of_inventory;						
	else list = list_of_items;															
	
	for (var i = 0; i < ds_list_size(list); i ++){											
		var draw_x = start_x + (i * item_width);
		var draw_y = start_y;
		var item = list[| i];																
		
		if (state == e_shop_states.sell) var quantity = "x" + string ( global.inventory[| item] );
		else quantity = "";
		
		//Draw background and item sprite
		draw_sprite_ext(spr_item_bg, 0, draw_x, start_y, scale, scale, 0, c_white, 1);
		draw_sprite_ext(spr_items, item, draw_x, start_y, scale, scale, 0, c_white, 1);
		
		//Draw Quantity
		draw_set_halign(fa_right);
		draw_set_valign(fa_bottom);
		draw_set_colour(c_yellow);
		draw_set_font(fnt_editor);
		draw_text(draw_x + (item_width / 2), draw_y + (item_height / 2), quantity );		
		
		//Show if selected
		if (selected_option == i){
			draw_set_alpha(0.5);
			draw_set_colour(c_white);
			draw_rectangle(draw_x - (item_width / 2), draw_y - (item_height / 2), draw_x + (item_width / 2), draw_y + (item_height / 2), false);
			draw_set_alpha(1);
		}
		
		#region Draw Buy/Sell price															
		
		draw_set_halign(fa_right);
		draw_set_valign(fa_top);
		draw_set_colour(c_white);
		draw_set_font(fnt_editor);
		
		var item_cost = real ( global.items[# item, e_item_stats.cost] );
		if (state == e_shop_states.sell) item_cost = floor ( item_cost * price_sell_modifier );
		
		draw_x = draw_x + ( (sprite_get_width(spr_items) * scale) / 2);
		draw_y = draw_y - ( (sprite_get_height(spr_items) * scale) / 2);
		
		draw_text(draw_x, draw_y, string ( item_cost ) + "g");
		
		#endregion
	}	
	
	#endregion
	
}

#region DISPLAY PLAYER GOLD						

draw_set_halign(fa_left);
draw_set_valign(fa_bottom);
draw_set_colour(c_white);
draw_set_font(fnt_conversation);

var gp = global.ds_values[| e_values_to_track.gold];
var display_gp = string(gp);

//Make sure we're not displaying huge long numbers
if gp > 999{
	display_gp = string_copy( string ( gp / 1000 ), 1, 2 );
	display_gp += "k";
}else

draw_text(margin, display_get_gui_height() - margin, display_gp + " g" );

#endregion
/* Testing/Debug
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_text(0, 0, "selected_option: " + string(selected_option) );