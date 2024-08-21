/// @function scr_ellipse_setup(list_of_units, draw_queue)
/// @description setup the variables for drawing the units in a radial manner
/// @param list_of_units {real} the list that holds the indexs of units that we want to draw
/// @param draw_queue {real} the queue that holds the information about which unit to draw, where to draw it, and its scale (stored in a list)

function scr_ellipse_setup(list_of_units, draw_queue){
	
	show_debug_message("running scr_ellipse_setup");
	//has the army screen finished rotating the units?		
	finished_rotating = true;											
	start_angle = 270;				
	wanted_angle = start_angle; //This variable will cause a rotation to happen as start_angle will always try to be equal to wanted_angle
	angle_diff = 360 / ds_list_size(list_of_units);		
	
	//Clear the draw queue
	ds_priority_clear(draw_queue);
	
}