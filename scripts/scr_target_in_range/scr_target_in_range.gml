/// @function scr_target_in_range(current_actor, queue_of_items, list_of_actors, movement_points)
/// @description Check a list of targets to see if they're in range of an attack/healing spell
/// @param {real} current_actor id of the current actor to save typing
/// @param {real} queue_of_items a priority queue of items we want to check the range of
/// @param {real} list_of_actors a list of actors that we want to check to see if they're within range of the items
/// @param {real} movement_points how far can the current_actor move?
function scr_target_in_range(argument0, argument1, argument2, argument3) {

	var ca = argument0
	var item_queue = argument1;
	var list_of_actors = argument2;
	var movement_points = argument3;
	var total_items = ds_priority_size(item_queue);

	for (var i = 0; i < total_items; i ++){
	
		//Get the min/max range of the current item
		var item = ds_priority_delete_max(item_queue); //offensive items will need to be added with a priority of the ABS of their value eg -50 = 50;
		var max_range = real( global.items[# item, e_item_stats.max_range] );
		var min_range = real( global.items[# item, e_item_stats.min_range] );
		show_debug_message("");
		show_debug_message("min_range: " + string(min_range));
		show_debug_message("max_range: " + string(max_range));
	
		show_debug_message("item being checked against list of targets: " + string(item) + ": " + global.items[# item, e_item_stats.name]);
	
		for (var j = 0; j < ds_list_size(list_of_actors); j ++){
	
			var target = list_of_actors[| j];
			show_debug_message("target: " + string(target));
			var distance_of_target = 0;
			
			//This calculation will give us a decent indication of whether a target is within range or not, and whether it's worth checking for a path or not
			distance_of_target += abs(ca.grid_x - target.grid_x);
			distance_of_target += abs(ca.grid_y - target.grid_y);
		
			show_debug_message("distance_of_target: " + string(distance_of_target));
	
			if (distance_of_target >= min_range && distance_of_target <= max_range){
			
				show_debug_message("TARGET IS WITHIN WEAPON RANGE, NO NEED TO MOVE");
			
			#region Target is within weapon range, no need to move
			
				//Remove MP
				ca.a_stats[e_stats.mp_current] -= global.items[# item, e_item_stats.mana_cost];
			
				//Check for consumable
				scr_remove_if_consumable(ca, item);
			
				//Update list_of_active_nodes with AoE
				var start_node = obj_scene.node_grid[# target.grid_x, target.grid_y];
				var min_range = 0;
				var max_range = global.items[# item, e_item_stats.aoe_range];
													
				scr_display_action_nodes(start_node, min_range, max_range, true, 1, false, obj_scene.list_of_active_nodes);
			
				//Create list to tell the Ai manager what action to run and add it to the ai_action_queue
				var list = ds_list_create();
			
				list[| 0] = item;
				list[| 1] = global.items[# item, e_item_stats.item_type];
					
				ds_priority_add(ai_action_queue, list, ds_priority_size(ai_action_queue) );
				show_debug_message(" !!! AI ACTION TAKEN !!! target is within range of an attack");
				show_debug_message( "item used: " + global.items[# item, e_item_stats.name] );
			
				if ds_exists(item_queue, ds_type_queue) ds_queue_destroy(item_queue);						
				if ds_exists(list_of_actors, ds_type_list) ds_list_destroy(list_of_actors);					
				return(true);
			
			#endregion

			}else{
				//If the target is below min range or above max range but movement might be able to get us to within range, see if 
				//we can move within range and then take the action as well
				if (distance_of_target < min_range) && (abs(distance_of_target - min_range) <= movement_points) ||
				   (distance_of_target > max_range) && (distance_of_target <= (max_range + movement_points)){
					show_debug_message("");
					show_debug_message("TARGET IS OUTSIDE ITEM RANGE, BUT WE MIGHT BE ABLE TO MOVE AND TARGET THEM");
				
				#region TARGET IS OUTSIDE ITEM RANGE, BUT WE MIGHT BE ABLE TO MOVE AND TARGET THEM					
				
					//We're looking for a tile we can move to that isn't occupied and is the minimum distance away from the target
					var start_node = obj_scene.node_grid[# ca.grid_x, ca.grid_y];
					scr_display_action_nodes(start_node, 0, movement_points, false, 1, true, list_of_active_nodes);
				
					show_debug_message("scr_target_in_range: size of list_of_active_nodes: " + string(ds_list_size(list_of_active_nodes)));
					var node = noone;
				
					//If the list size is greater than 0 there are some nodes we might be able to move to
					if (ds_list_size(list_of_active_nodes) > 0){
					
						show_debug_message("list_of_active_nodes size > 0");
					
						for (var k = 0; k < ds_list_size(list_of_active_nodes); k ++){
							var node = list_of_active_nodes[| k];
						
							//Have to calculate grid_x/y difference separately
							var difference = ( abs ( node.grid_x - target.grid_x ) + abs (node.grid_y - target.grid_y) );
						
							//show_debug_message("node_score: " + string(node_score));
							show_debug_message("difference between node and target score: " + string(difference));
						
							if ( difference >= min_range && difference <= max_range ){
							
								show_debug_message("node is within range");
								//We have a node that we can move to, that is also within the min/max range of the item
							
							#region Make actor move
							
								var start_node = obj_scene.node_grid[# ca.grid_x, ca.grid_y];
								var end_node = node;
						
								//scr_display_action_nodes(start_node, 1, 4, false, 1, true, obj_scene.list_of_active_nodes); //don't think we need this as we already ran scr_dispaly_action_nodes
								scr_generate_path(start_node, end_node, obj_scene.path_queue);
						
								//Now we want to limit the path by the actor's movement range
								//while (ds_priority_size(obj_scene.path_queue) >= 4) ds_priority_delete_min(obj_scene.path_queue); //don't need this as it's within movement range
						
								//make the actor move
								with ca{														
									moving = true;																	
									has_moved = true;
									target_node = scr_get_next_path_node(obj_scene.path_queue);
								}
										
								//Remove actor id from its grid position in actor_grid				
								actor_grid[# ca.grid_x, ca.grid_y] = noone;	
								obj_scene.current_action = e_battle_menu.move;
								with obj_AI_manager state = e_actions.wait_for_animation_end;
							
							#endregion
							
							#region Queue up an action
							
								//Remove MP
								ca.a_stats[e_stats.mp_current] -= global.items[# item, e_item_stats.mana_cost];
			
								//Check for consumable
								scr_remove_if_consumable(ca, item);
			
								//Update list_of_active_nodes with AoE
								show_debug_message("Filling list with nodes for AoE")
								var min_range = 0;
								var max_range = global.items[# item, e_item_stats.aoe_range];
								show_debug_message("AoE min range: " + string(min_range));
								show_debug_message("AoE max_range: " + string(max_range));
								scr_display_action_nodes(obj_scene.node_grid[# target.grid_x, target.grid_y], min_range, max_range, true, 1, false, obj_scene.list_of_active_nodes);
			
								//Create list to tell the Ai manager what action to run and add it to the ai_action_queue
								var list = ds_list_create();
			
								list[| 0] = item;
								list[| 1] = global.items[# item, e_item_stats.item_type];
					
								ds_priority_add(ai_action_queue, list, ds_priority_size(ai_action_queue) );
							
							#endregion
							
								show_debug_message(" !!! AI ACTION TAKEN !!! ca has to move first");
								show_debug_message(" ca grid_x/grid_y: " + string(ca.grid_x) + "/" + string(ca.grid_y));
								show_debug_message(" target grid_x/grid_y: " + string(target.grid_x) + "/" + string(target.grid_y));
								show_debug_message(" node grid_x/grid_y: " + string(node.grid_x) + "/" + string(node.grid_y));
								show_debug_message( "item used: " + global.items[# item, e_item_stats.name] );
								show_debug_message(" min/max range: " + global.items[# item, e_item_stats.min_range] + "/" + global.items[# item, e_item_stats.max_range] );
								show_debug_message( "ca: " + string(ca) + " | target: " + string(target));
								show_debug_message( "list_of_active_nodes size (from scr_target_in_range): " + string(ds_list_size(obj_scene.list_of_active_nodes)));
							
								obj_AI_manager.target = target;
								if ds_exists(item_queue, ds_type_queue) ds_queue_destroy(item_queue);					
								if ds_exists(list_of_actors, ds_type_list) ds_list_destroy(list_of_actors);			
								return(true);
							
							}
						}
					}
				
				#endregion
				
				}
			
				/*																<=== COMMENTED OUT EPISODE 24
				show_debug_message(" !!! AI ACTION NOT TAKEN !!! Nobody is within range for attacking/healing or nobody needs healing etc");
			
				if ds_exists(item_queue, ds_type_queue) ds_queue_destroy(item_queue);						
				if ds_exists(list_of_actors, ds_type_list) ds_list_destroy(list_of_actors);				
				return false;
				*/
			}
		}
	
	}
	//<=== code moved here EPISODE 24
	show_debug_message(" !!! AI ACTION NOT TAKEN !!! Nobody is within range for attacking/healing or nobody needs healing etc");
			
	if ds_exists(item_queue, ds_type_queue) ds_queue_destroy(item_queue);						
	if ds_exists(list_of_actors, ds_type_list) ds_list_destroy(list_of_actors);				
	return false;


}
