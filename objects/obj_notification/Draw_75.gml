scale = 2;
item_width = sprite_get_width(spr_items) * scale;
item_height = sprite_get_height(spr_items) * scale;
unit_width = sprite_get_width(spr_iso_actor_idle_s) * scale;
unit_height = sprite_get_height(spr_iso_actor_idle_s) * scale;

start_x = (display_get_gui_width() / 2) - 300;
start_y = display_get_gui_height() - 180;

//DRAW BLACK BACKGROUND
var x1 = 0; var x2 = display_get_gui_width(); var y1 = display_get_gui_height(); var y2 = y1 - 220;
draw_set_colour(c_black);
draw_rectangle(x1, y1, x2, y2, false);

#region SHOW HOW MUCH GOLD WAS GAINED

var text = string( gold );
draw_set_colour(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_center);
draw_set_font(fnt_conversation);
draw_text(start_x, start_y, "GOLD: " + text + "g !!!");

#endregion

#region SHOW WHAT ITEMS WERE GAIN

draw_text(start_x, start_y + item_height, "ITEMS: ");

for (var i = 0; i < ds_list_size(items_list); i ++){
	var item = items_list[| i];
	var draw_x = start_x + (item_width / 2) + (i * item_width) + string_width("ITEMS: ");
	var draw_y = start_y + item_height;
	
	draw_sprite_ext(spr_items, item, draw_x, draw_y, 2, 2, 0, c_white, 1);
}

#endregion

#region SHOW WHAT UNITS WERE GAIN

draw_text(start_x, start_y + item_height + unit_height, "UNITS: ");

for (var i = 0; i < ds_list_size(units_list); i ++){
	var unit = units_list[| i];
	var draw_x = start_x + (unit_width / 2) + (i * unit_width) + string_width("UNITS: ");
	var draw_y = start_y + item_height + unit_height + 20;
	
	scr_army_screen_draw_unit(unit, draw_x, draw_y, 2, e_facing.south, false, e_battle_menu.move, 0, 1, c_white);
}

#endregion

//show "OK" if this message is read to be destroyed and they player hasn't yet pressed OK
if (timer >= wait_time){
	draw_set_valign(fa_bottom);
	draw_set_halign(fa_right);
	draw_text(display_get_gui_width(), display_get_gui_height(), "OK" );
}