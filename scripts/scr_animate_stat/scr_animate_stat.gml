/// @function scr_animate_stat(instance_id, value_to_display);
/// @description make a number float upwards 
/// @param instance_id the instance id of the object we want to animate
/// @param value_to_display - what number do we want to display
function scr_animate_stat(argument0, argument1) {

	var inst = argument0;
	var value_to_display = argument1;

	//Tell instance of obj_anim_stats to animate itself
	with inst{
		value = value_to_display;
		active = true;
		image_speed = 1; //Run the animation
	}

	//Tell obj_animation to wait for animation to finish
	with obj_animation{
		action_state = e_actions.wait_for_animation_end;
		actor_animating = inst;
		show_debug_message("scr_animate_stat - actor_animating: " + string(actor_animating));
	}

	//Add the stat object to the anim_grid so obj_scene will know to draw an animation
	obj_scene.anim_grid[# inst.grid_x, inst.grid_y] = inst;


}
