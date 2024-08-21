/// @function scr_animate_actor(instance_id, state_to_switch_to);
/// @description change the actors state/sprite, and focus the camera on the actor
/// @param instance_id the instance id of the actor we want to animate
/// @param state_to_switch_to what kind of animation? Attack? Spell? Item? etc

function scr_animate_actor(actor, state_to_switch_to) {

	//Tell the actor what animation to play
	scr_change_actor_state(actor, state_to_switch_to);

	//Center camera on actor
	with obj_scene scr_center_on_actor(actor);

	//Make Animation object wait until current animation is done so that we can
	//play all the animations in order
	with obj_animation{
		action_state = e_actions.wait_for_animation_end;
		actor_animating = actor;
		show_debug_message("scr_animate_actor - actor_animating: " + string(actor_animating));
	}

	#region SOUND
	
	var snd = -1;
	if (state_to_switch_to == e_actor_sprites.attack) snd = snd_swing;
	if (state_to_switch_to == e_actor_sprites.spell) snd = snd_spell;
	if (state_to_switch_to == e_actor_sprites.hurt) snd = snd_hurt;
	
	if (snd != -1) audio_play_sound(snd, 0, false);
	
	#endregion
}
