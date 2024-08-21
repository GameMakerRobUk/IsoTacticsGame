//If active, increase height (so that the number moves upwards)
if (active){
	//increase height (so that the number moves upwards)
	if (state == e_stat_anim.display_action_value) height += 0.5;
	
	if (state == e_stat_anim.display_xp_level){
		if (value > 0){
			image_index = 0; //Stop the animation playing
			value --;
			obj_scene.current_actor.a_stats[e_stats.xp] ++;
			
			//If the actor's xp reaches 100, level up and reset xp value
			if (obj_scene.current_actor.a_stats[e_stats.xp] >= 100){
				obj_scene.current_actor.a_stats[e_stats.xp] = 0;
				obj_scene.current_actor.a_stats[e_stats.level] ++;
				scr_levelup(obj_scene.current_actor);
			}
		}
	}
}
