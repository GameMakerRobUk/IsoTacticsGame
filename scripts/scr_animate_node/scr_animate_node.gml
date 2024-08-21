/// @function scr_animate_node(instance_id, unused_argument);
/// @description change the nodes sprite, and focus the camera on the actor
/// @param instance_id the instance id of the node we want to animate
/// @param unused_argument - have the same number of arguments as scr_animate_actor
function scr_animate_node(argument0) {

	var node = argument0;

	//Change sprite of node
	node.sprite_index = spr_iso_spell_anim;

	//Center camera on actor
	with obj_scene scr_center_on_actor(node);

	//Make Animation object wait until current animation is done so that we can
	//play all the animations in order
	with obj_animation{
		action_state = e_actions.wait_for_animation_end;
		actor_animating = node;
		show_debug_message("scr_animate_node - actor_animating: " + string(actor_animating));
	}


}
