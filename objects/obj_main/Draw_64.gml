if (room == rm_first){

	var gw = display_get_gui_width();
	var gh = display_get_gui_height();

	if (global.main_state == e_main_states.title_screen){
	
		#region TITLE SCREEN
	
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		draw_set_colour(c_white);
		draw_set_font(fnt_conversation);
	
		draw_text(gw/2, gh/2, "TITLE SCREEN");
	
		#endregion
	
	}

	if (global.main_state == e_main_states.display_save_files){
	
		#region DISPLAY SAVE FILES
	
		//How high/wide are the save slots?
		var slot_height = floor( (gh - 100) / 3 );
		var slot_width = gw/2;
		var margin = 20;
	
		for (var i = 0; i < 3; i ++){
		
			//Setup coordinates for drawing the save slots
			var x1 = (gw / 2) - (slot_width / 2);
			var x2 = (gw / 2) + (slot_width / 2);
			var y1 = ( ( gh/2 ) - (slot_height + margin) ) + (i * ( slot_height + margin) ) - slot_height/2;
			var y2 = y1 + slot_height;
		
			//Draw Save slot rectangle
			if (global.current_save_file == i) draw_set_color(c_white);
			else draw_set_colour(c_dkgray);
		
			draw_rectangle(x1, y1, x2, y2, true);
		
			//Show Date or NO DATA
			var str = save_slot_dates[i];
		
			draw_set_halign(fa_center);
			draw_set_valign(fa_middle);
		
			draw_text(gw/2, y1 + (slot_height / 2), str);
		}
	
		#endregion
	
	}

}

if (global.main_state == e_main_states.credits){
	
	#region CREDITS
	
	for (var i = 0; i < array_length(a_credits); i ++){
		var text = a_credits[i];
		
		draw_set_colour(c_white);
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		draw_set_font(fnt_conversation);
		
		var draw_y = credit_y + (i * 40);
		
		draw_text(credit_x, draw_y, text);
	}
	
	#endregion
	
}