if (state == e_actions.get_next_action && obj_scene.current_actor.moving == false){
	
	show_debug_message("obj_AI_manager - get next action");
	
	#region GET NEXT ACTION
	
	if (ds_priority_size(ai_action_queue) > 0){
		
		/*
			list[| 0] = item;
			list[| 1] = current_action;
		*/
		show_debug_message("Size of ai_action_queue is greater than 0");
		
		var list = ds_priority_delete_min(ai_action_queue);
		
		var action = list[| 1];
		
		if (action != e_battle_menu.move){
			show_debug_message("action is not equal to move: " + obj_scene.a_battle_menu_text[action]);
			obj_scene.current_action = action;
			show_debug_message("setting obj_scene.current_action to " + obj_scene.a_battle_menu_text[action]);
			//make an animation object
			var animate_the_action = instance_create_depth(0,0,0,obj_animation);					
			animate_the_action.state = e_animations.take_an_action;		
			animate_the_action.item = list[| 0];	
		}
		
		show_debug_message("obj_AI_manager - running next action");
		state = e_actions.wait_for_animation_end;
		
		//If this is the last action, destroy this object
		if (ds_priority_size(ai_action_queue) == 0){
			show_debug_message("Destroying obj_ai_manager as queue is empty");
			instance_destroy();
		}
	}else{
		show_debug_message("Setting obj_scene battle state to next_actor");
		obj_scene.battle_state = e_battle.next_actor;
		instance_destroy();	
	}
	
	#endregion
	
}else{
	
	if (state == e_actions.wait_for_animation_end){
		
		#region WAIT FOR ANIMATION END
		
		if (instance_exists(obj_animation) ){
			
		}else{
			//There is no instance of obj_animation
			if (obj_scene.current_action == e_battle_menu.choose_facing){
				
				//Run script to change facing, but need grid_x/grid_y to pass to script
				if (timer == 0){
					if (target != noone){
						obj_scene.current_actor.facing = scr_facing(obj_scene.current_actor, target.grid_x, target.grid_y);
					}
				}
				
				timer ++;
				if (timer >= room_speed){
					
					timer = 0;
					obj_scene.current_action = e_battle_menu.awaiting_action;
					state = e_actions.get_next_action;
				
					show_debug_message("setting obj_scene current_action to awaiting_action");
				}
			}
		}
		
		#endregion
		
	}
	
}