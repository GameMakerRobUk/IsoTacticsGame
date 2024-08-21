/// @description DRAW EQUIPPED ITEMS FOR UNITS - TESTING PURPOSES ONLY

/*
var y_counter = 0;

for (var yy = e_characters.butz; yy < ds_grid_height(global.character_stats); yy ++){
	
	var x_counter = 0;
	
	for (var xx = e_stats.left_hand; xx <= e_stats.item_2; xx ++){
		var draw_x = 20 + (x_counter * 40);
		var draw_y = 20 + (y_counter * 20);
		
		var item_id = global.character_stats[# xx, yy];
		
		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		draw_set_colour(c_white);
		draw_set_font(fnt_editor);
		
		draw_text(draw_x, draw_y, string(item_id) );
		
		x_counter ++;
	}
	
	y_counter ++;
}