if (state != e_animations.take_an_action){ 															
	
	#region BATTLE INTRO /VICTORY/DEFEAT
	
	if (left_x < target_x) left_x += pixels_to_move_per_step;
	if (right_x > target_x) right_x -= pixels_to_move_per_step;
	
	else{
		timer ++;
		
		if (timer >= (room_speed * 2) ){
			instance_destroy();
			if (state == e_animations.battle_intro) obj_scene.battle_state = e_battle.setup_turn_order;
							
			#region VICTORY											
			
			if (state == e_animations.victory || state == e_animations.defeat){	
					
				//Update character_classes grid with stats from obj_actor
				with (obj_actor){
					if (a_stats[e_stats.in_players_team]){
						for (var i = 0; i < e_stats.last; i ++){
							if (a_stats[e_stats.hp_current] <= 0) value = ""; //remove character from the grid
							else value = string(a_stats[i]);
							
							global.character_stats[# i, actor_id] = value;
						}
						
						//Refill HP/MP for survivors
						if (a_stats[e_stats.hp_current] > 0){
							global.character_stats[# e_stats.hp_current, actor_id] = global.character_stats[# e_stats.hp_max, actor_id];
							global.character_stats[# e_stats.mp_current, actor_id] = global.character_stats[# e_stats.mp_max, actor_id];
						}
					}
				} 
				
				scr_rewards();
				
				if (global.ds_values[| e_values_to_track.story_state] >= e_story.last){ 
					global.main_state = e_main_states.credits; 
					room_goto(rm_first);
				}
			}
					
			#endregion
			
			#region DEFEAT									
					
			if (state == e_animations.defeat){
				global.main_state = e_main_states.title_screen;	
				room_goto(rm_first); 
			}
					
			#endregion
			
		}
	}
	
	#endregion
	
}

if (state == e_animations.take_an_action){
	
	#region TAKE AN ACTION																	
	
	#region FILL QUEUE WITH LISTS AND ARGUMENTS SO WE CAN PLAY THEM IN ORDER						
	
	if (action_state = e_actions.initialise){
		
		show_debug_message("obj_animation action_state is initialise");
		#region INITIALISE																			
		
		var list = ds_list_create();
		ds_list_add(list, scr_animate_actor, obj_scene.current_actor, obj_scene.current_action);
		
		//Add list to queue
		ds_priority_add(animation_queue, list, ds_priority_size(animation_queue));
		
		//track how much xp current_actor gains														
		xp_gained = 0;
		
		//Go through all the nodes stored in list_of_active_nodes - These nodes are all part of the AoE effect, whether it's just 1 tile or 20
		
		#region BUILD QUEUE OF ANIMATIONS THAT WE WANT TO SHOW IN ORDER							
		
		show_debug_message("list_of_active_nodes size: " + string(ds_list_size(obj_scene.list_of_active_nodes)));
		
		for (var i = 0; i < ds_list_size(obj_scene.list_of_active_nodes); i ++){
			//If it's a spell we want to show an animation for each tile
			//Otherwise, we only want an animation if an actor is in the tile
			
			var node = obj_scene.list_of_active_nodes[| i];
			
			if (obj_scene.current_action == e_actor_sprites.spell || obj_scene.actor_grid[# node.grid_x, node.grid_y] != noone){
			
				if (obj_scene.current_action == e_actor_sprites.spell){
					show_debug_message("obj_scene current_action is a spell");
					list = ds_list_create();
					ds_list_add(list, scr_animate_node, node, -1);							
					show_debug_message("scr_animate_node added to animation_queue");
					//Add list to queue
					ds_priority_add(animation_queue, list, ds_priority_size(animation_queue));
				}
			
				//Check for an actor to animate
				var actor = obj_scene.actor_grid[# node.grid_x, node.grid_y];
				
				if (actor != noone){
					show_debug_message("there's an actor("+ string(actor) +") on this node");
					list = ds_list_create();
					ds_list_add(list, scr_animate_actor, actor, e_actor_sprites.hurt);
					show_debug_message("scr_animate_actor added to animation_queue");
					//Add list to queue
					ds_priority_add(animation_queue, list, ds_priority_size(animation_queue));
					
					#region ADD A NUMBER ANIMATION AND CALCULATE STAT EFFECT TOO					
					
					//Calculate Effect
					var value = scr_action_calculation(obj_scene.current_actor, actor, item);						
					
					#region Update xp_gained																			
					
					var target_level = (actor.a_stats[e_stats.level] + 1 );
					var ca_level = obj_scene.current_actor.a_stats[e_stats.level];
					var xp_for_hit = 10 * (target_level - ca_level);
					xp_for_hit = clamp(xp_for_hit, 5, 30);
					
					if (value == 0) xp_for_hit = 1;																	
					xp_gained += xp_for_hit;
					
					#endregion
					
					#region Calculate Effects																	
					//Add Animation
					list = ds_list_create();
					var stat_object = instance_create_depth(0, 0, 0, obj_anim_stats);
					
					with stat_object{
						state = e_stat_anim.display_action_value;
						grid_x = node.grid_x;
						grid_y = node.grid_y;	
					}
					
					ds_list_add(list, scr_animate_stat, stat_object, value);
					show_debug_message("scr_animate_stat added to animation_queue");
					//Add list to queue
					ds_priority_add(animation_queue, list, ds_priority_size(animation_queue));
					
					//Is this actor dead? If so, it's another animation to add
					if (actor.a_stats[e_stats.hp_current] <= 0){
						//Yes!
						list = ds_list_create();
						ds_list_add(list, scr_actor_dies, actor, -1);
						show_debug_message("scr_actor_dies added to animation_queue");
						//Add list to queue
						ds_priority_add(animation_queue, list, ds_priority_size(animation_queue));
					}
					
					#endregion
				
					#endregion
					
				}
			}
		}
		
		//Clear the active node list now
		ds_list_clear(obj_scene.list_of_active_nodes);
		show_debug_message("list_of_active_nodes cleared from obj_animation");
		#endregion
		
		//Change state to play animations
		action_state = e_actions.get_next_action;
		
		#endregion
		
	}
	
	#endregion
	
	if (action_state == e_actions.get_next_action){
		#region GET NEXT ACTION																	
		
		if (ds_priority_size(animation_queue) > 0){
			
			#region Run the next script to be played in the animation
			
			var list = ds_priority_delete_min(animation_queue);
			
			var script = list[| 0];
			var arg0 = list[| 1];
			var arg1 = list[| 2];
			
			script_execute(script, arg0, arg1);
			
			ds_list_destroy(list); //get rid of the list we just used
			
			#endregion
			
		}else{
			if (added_xp_animation == false){	
				
				#region ADD ANIMATION TO SHOW XP / LEVELS GAINED											
				//only for player-controlled units and those who are still alive
				if (obj_scene.current_actor.a_stats[e_stats.in_players_team] && obj_scene.current_actor.a_stats[e_stats.hp_current] > 0){
		
					var stat_object = instance_create_depth(0, 0, 0, obj_anim_stats);
					
					with stat_object{
						state = e_stat_anim.display_xp_level;
						grid_x = obj_scene.current_actor.grid_x;
						grid_y = obj_scene.current_actor.grid_y;
					}
				
					scr_animate_stat(stat_object, xp_gained);
				}

				added_xp_animation = true;
		
				#endregion
				
			}else{																							
				//All animations are done
				if (obj_scene.battle_state != e_battle.defeat)						
					obj_scene.battle_state = e_battle.next_actor;
				instance_destroy();
			}																								
		}
		
		#endregion
		
	}else{
	
		if (action_state == e_actions.wait_for_animation_end){
			
			#region WAIT FOR ACTOR TO FINISH THE ANIMATION											

			if (actor_animating != noone){
				if (actor_animating.image_index >= (actor_animating.image_number - 1) ){
	
					if (timer == 0){
						//Reset actors/nodes
						
						//Reset Node (only nodes should have the spell sprite assigned)
						//if (actor_animating.sprite_index == spr_iso_spell_anim){					
						if (actor_animating.object_index == obj_node){							
							actor_animating.sprite_index = -1;
							actor_animating.image_index = 0;
						}else{
							if (actor_animating.object_index == obj_anim_stats){					
								obj_scene.anim_grid[# actor_animating.grid_x, actor_animating.grid_y] = noone;
								with actor_animating active = false;									
							}else{																	
								//Reset actor	
					
								//Check to see if actor is dead
								if (actor_animating.sprite_index == spr_iso_actor_dies){			
		
									with actor_animating{												
										state = e_actor_sprites.dead;									
										sprite_index = -1;												
									}																	
									//Remove actor from actor_grid to make the node passable
									obj_scene.actor_grid[# actor_animating.grid_x, actor_animating.grid_y] = noone; 
								}else{

									scr_change_actor_state(actor_animating, e_actor_sprites.idle);
								}
							}
						}
					}
					
					//We want a pause before switching to next animation
					timer ++;
					
					if (timer >= 20){
						timer = 0;
						action_state = e_actions.get_next_action;
					}
				}
			}
		
			#endregion
			
		}
	
	}
	
	#endregion
	
}