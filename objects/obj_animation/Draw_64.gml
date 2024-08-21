if (state != e_animations.take_an_action){
	draw_set_font(fnt_battle_intro);   
	draw_set_valign(fa_middle);
	
	draw_set_halign(fa_right);
	draw_text(left_x, start_y, a_txt[state, 0]);
	
	draw_set_halign(fa_left);
	draw_text(right_x, start_y, a_txt[state, 1]);
}