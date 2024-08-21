/// @description Formerly obj_test

/*
	Have a variable that determines the mission to load
	load the map based on the mission_grid + variable
	play through the conversation in the step event
*/

iso_width = sprite_get_width(spr_iso_width_height);
iso_height = sprite_get_height(spr_iso_width_height);
display_all_heights = true;

//mission_to_load = 0; //Which mission is being played?
conversation_entry = 0; //This entry will increase by 1 until it reaches the height of the conversation csv

//SETUP GRID
total_maps = 0;
battle_map_list = ds_list_create();

ds_terrain_data = ds_grid_create(1, 1); //tile grid
var list = ds_list_create();
ds_terrain_data[# 0, 0] = list; //Adding a list to the grid to prevent errors from inside scr_load_map

map_index_to_load = real ( global.story_points[# e_path_point_setup.map, e_story.a_debriefing] );

scr_load_game_data();
scr_load_map(map_index_to_load, ds_terrain_data, battle_map_list);

show_map = false;		

enum e_misc_states{																						
	idle,																									
	setup_battle,                                                                                     
	choose_units,
	display_reserve,														
	conversation,
	in_battle,
	done,
}

state = e_misc_states.idle;			
spawn_tile_list = ds_list_create();		
selected_option = 0;															
prev_selected_option = -1;													
reserve_list = ds_list_create();												
mandatory_list = ds_list_create();												
temp_list = ds_list_create(); // we need a spare list to hold data to transfer between spawn points 

enum e_battle{																							
	not_ready,
	setup_turn_order,	
	next_actor,
	actor_taking_turn,
	running_action,		
	ai_controlled,														
	defeat,																			
	victory,																
}

enum e_battle_menu{														
	awaiting_action,
	move,
	attack,
	spell,
	item,
	choose_facing,	
}

a_battle_menu_text[e_battle_menu.awaiting_action] = "NOT USED";			
a_battle_menu_text[e_battle_menu.move] = "MOVE";
a_battle_menu_text[e_battle_menu.attack] = "ATTACK";
a_battle_menu_text[e_battle_menu.spell] = "SPELL";
a_battle_menu_text[e_battle_menu.item] = "ITEM";
a_battle_menu_text[e_battle_menu.choose_facing] = "NOT USED";

#region initialise DATA STRUCTURES

//What action is the Unit taking?
current_action = e_battle_menu.awaiting_action;						

//This grid holds all the node instances (used for pathing and related stuff)
node_grid = ds_grid_create(1, 1);																		

//This grid holds all the actor instances
actor_grid = ds_grid_create(1, 1);									

//This grid will hold obj_anim_stats																		
anim_grid = ds_grid_create(1, 1);

//This list will hold the id's of the actors and the actors will take their turn in the order that they appear in the queue
turn_list = ds_list_create();		

//Holds the instance_ids of any nodes within "range" - whether that's for attacks / spells or moving etc
list_of_active_nodes = ds_list_create();			

//Holds the instance_ids of any nodes that are on a movement path
path_queue = ds_priority_create();		

#endregion

//Units will move around in a 2D grid but we'll DRAW it in isometric - we'll see a 2D representation later on
#macro GRID_SIZE 16		
#macro UNIT_MOVE_SPEED 2 //how fast will units move in battle? Speeds up the game
#macro ACTOR_ANIMATION_SPEED 0.25;

//This state runs while state = e_misc_state.in_battle
battle_state = e_battle.not_ready;																	

//The instance id of the current unit's turn
current_actor = noone;			

grid_x = 0;											
grid_y = 0;			

//Setup Battle Menu Lists																							
/*
	We're creating a list (battle_menu_lists) that will store several lists - 1 for each action in the battle menu
	These lists will start out as empty and when it's an actors turn, the menu actions will be populated by the
	actions that the actor can take based on its items. Eg if an actor has a sword and a bow, they will see
	Sword
	Bow
	in the "Attack" battle menu option
	Having (battle_menu_lists) hold the rest allows us to use for loops and minimize code
*/
battle_menu_lists = ds_list_create();																				

for (var i = 0; i < e_battle_menu.choose_facing; i ++){																
	var list = ds_list_create();
	ds_list_add(battle_menu_lists, list);
}

secondary_option = -1; //if -1 then player is still picking an option from the main menu							
					   //if 0 or greater, player is picking a secondary option like Sword / Bow / Fireball
					   
					   
#region RADIAL DISPLAY + ROTATION - The thing that displays units on an ellipse				

//This queue will holds the lists that contain the info about what unit to draw, where to draw, its scale etc
draw_queue = ds_priority_create();						

//SET DRAW VARIALBES FOR ELLIPSE
g_w = display_get_gui_width();
g_h = display_get_gui_height();
ellipse_draw_x = (g_w / 2);
ellipse_draw_y = (g_h / 2) + 100;
ellipse_width = 360;
ellipse_height = ellipse_width / 4;
finished_rotating = true;

#endregion
					   