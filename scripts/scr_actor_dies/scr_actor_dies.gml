/// @function scr_actor_dies(instance_id, empty_var);
/// @description change sprite of actor to spr_iso_actor_dies
/// @param instance_id the instance id of the object we want to animate
/// @param empty_var -1 will do we wont use this argument
function scr_actor_dies(argument0) {

	show_debug_message("scr_actor_dies script running");

	var actor = argument0;

	show_debug_message("mandatory: " + string(actor.a_stats[e_stats.must_survive_this_battle]));

	with actor{
		state = e_actor_sprites.dead;
		image_index = 0;
		image_speed = 0.25;
		sprite_index = spr_iso_actor_dies;
	}

	//Tell obj_animation to wait for animation to finish
	with obj_animation{
		action_state = e_actions.wait_for_animation_end;
		actor_animating = actor;
	}

	//Remove this actor from the turn list if they're in it
	if (ds_list_find_index(obj_scene.turn_list, actor) != -1){
		var pos = ds_list_find_index(obj_scene.turn_list, actor);
		ds_list_delete(obj_scene.turn_list, pos);
	}

	//Was the actor mandatory? [Note: only player units should be mandatory]				
	if (actor.a_stats[e_stats.must_survive_this_battle]){
		show_debug_message("!!!");
		show_debug_message("Mandatory character killed");
		show_debug_message("!!!");
		obj_scene.battle_state = e_battle.defeat;
	}
	
	audio_play_sound(snd_died, 0, false);	//<=== NEW EPISODE 30
}
