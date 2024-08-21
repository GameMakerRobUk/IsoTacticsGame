enum e_army_states{
	choose_unit,
	display_options,
	change_class,
	change_equipment,
	fire_unit,
	last,
}

a_option_text[e_army_states.change_class] = "CHANGE CLASS";
a_option_text[e_army_states.change_equipment] = "CHANGE GEAR";
a_option_text[e_army_states.fire_unit] = "FIRE UNIT";

army_list = ds_list_create(); //Will hold the entries from global.character_stats of units that are in the player's army so "2" if the 3rd entry is in the player's army
stats_to_display = ds_list_create(); //Will hold the stats we want to display for a particular unit
scr_sort_stats(stats_to_display);

stat_text_grid = load_csv("stat_strings.csv");

selected_unit = 0;
selected_option = e_army_states.change_class;

state = e_army_states.choose_unit;

#region Add Units to army list

//Run through grid and add units to list
for (var yy = 0; yy < ds_grid_height(global.character_stats ); yy ++){
	
	//Check to see if this unit is "in_players_team"
	if (global.character_stats[# e_stats.in_players_team, yy] == "1"){
		ds_list_add(army_list, yy);
	}
	
}

#endregion

//Create list that will dynamcailly store items that can be equipped in the currently selected spot eg weapons for left/right hand
gear_list = ds_list_create();					
show_gear_list = false; //Show the gear list or not   

#region ARMY SCREEN RADIAL DISPLAY + ROTATION						

//This queue will holds the lists that contain the info about what unit to draw, where to draw, its scale etc
units_to_draw = ds_priority_create();				

scr_ellipse_setup(army_list, units_to_draw);		

//SET DRAW VARIALBES FOR ELLIPSE
g_w = display_get_gui_width();
g_h = display_get_gui_height();
ellipse_draw_x = (g_w / 2);
ellipse_draw_y = (g_h / 2) + 100;
ellipse_width = 360;
ellipse_height = ellipse_width / 4;

//CREATE A LIST THAT HOLDS THE DIFFERENT CLASSES
list_of_classes = ds_list_create();					

for (var i = (e_characters.leave_empty + 1); i < e_characters.butz; i ++){ 
	ds_list_add(list_of_classes, i);			
}													

#endregion