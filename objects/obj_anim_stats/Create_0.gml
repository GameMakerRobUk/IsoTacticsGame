enum e_stat_anim{
	display_action_value,
	display_xp_level,
	last,
}

active = false; //if active == false, the object should be frozen
height = 0; //The "height" of the instance is added to draw_y to draw the number from obj_scene inside
            //the double for loop
image_speed = 0; //We dont want to run the animation until the game is ready