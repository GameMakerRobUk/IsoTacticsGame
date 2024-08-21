/// @function scr_change_actor_state(instance_id, state_to_switch_to);
/// @description change an actors state so that an animation will play
/// @param instance_id the instance id of the actor we want to animate
/// @param state_to_switch_to what kind of animation? Attack? Spell? Item? etc
function scr_change_actor_state(actor, state_to_switch_to) {

	//Tell the actor what animation to play
	with actor{
		image_index = 0;
		image_speed = ACTOR_ANIMATION_SPEED;
		state = state_to_switch_to;
		sprite_index = sprite_grid[# state, facing];
	}


}
