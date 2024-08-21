enum e_animations{
	battle_intro,
	take_an_action,	
	victory,			
	defeat,				
}

enum e_actions{									
	initialise,
	get_next_action,
	wait_for_animation_end,
}

timer = 0;

//Setup battle intro string
a_txt[e_animations.battle_intro, 0] = "BAT"; //starts off being drawn left of the screen
a_txt[e_animations.battle_intro, 1] = "TLE"; //starts off being drawn right of the screen
a_txt[e_animations.victory, 0] = "VIC";			
a_txt[e_animations.victory, 1] = "TORY";			
a_txt[e_animations.defeat, 0] = "DEF";				
a_txt[e_animations.defeat, 1] = "EAT";			

left_x = 0;
right_x = display_get_gui_width();
start_y = display_get_gui_height() / 2;
target_x = (right_x / 2); //Where should the text meet in the middle?
pixels_to_move_per_step = 4;

action_state = e_actions.initialise;				
actor_animating = noone;							
animation_queue = ds_priority_create();				
added_xp_animation = false;			

show_debug_message("obj_animation created. Instance_count: " + string(instance_number(obj_animation)));
