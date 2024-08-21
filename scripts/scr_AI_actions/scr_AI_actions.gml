/// @function scr_AI_actions(current_actor, battle_menu_lists, movement_points)
/// @description The Ai will decide what to do via this script
/// @param {real} current_actor
/// @param {real} battle_menu_lists
/// @param {real} movement_points how far can the actor move
function scr_AI_actions(argument0, argument1, argument2) {

	var ca = argument0;
	var battle_lists = argument1;
	var movement_points = argument2;
	var enemies = ds_list_create(); //Check to make sure the actors are alive
	var injured = ds_list_create(); //Check to make sure the actors are alive

	ai_action_queue = ds_priority_create(); //This queue will hold the actions that the AI needs to perform in order

	/*
		[HEALING] - First priority
		- Make a list of all friendlies with HP < 75% [including self] [if list size == 0, ignore the rest of this section]
		- Make a queue of all healing items, don't include spells that you don't have MP for [if queue size == 0 ignore the rest of this section]
		 - priority is given to those with biggest AoE
		- [If hp < 25%] Heal self
		- else [If AoE > 0] If there are multiple wounded that can be hit by AoE Heal, use that
		- else [If hp < 50% heal self]
		- else [Heal a single target]
	
		[DAMAGE - AoE favoured]
		- Make a queue of all damaging items, priority given to biggest AoE, don't add spells that you don't have MP for
		- Make a list of all enemies within range of the attack with highest priority
		- Check for spots that can hit multiple enemies and use that
		- else [Cast a spell on the nearest enemy]
		- else [Attack enemy with furthest ranged weapon]
		- else just move towards nearest enemy
	
		[If can't heal and can't damage anyone, just move towards nearest enemy]
		- Check for nearest enemy based on relative grid_x/grid_y - this won't always return the actual nearest enemy because 
		  no paths are involved, only the difference in coordinates
		- Calculate a path to get there, don't worry about movement range
		- Delete path points until only as many remain as the actor has movement range, and then move the actor
	*/

#region HEALING

	//Make a list of all friendlies with HP < 75% [including self] [if list size == 0, ignore the rest of this section]
	//var injured = ds_list_create();

	with obj_actor{
		//If this actor is on the same team as the current actor, check if they're injured and add them to the list
		if (a_stats[e_stats.in_players_team] == ca.a_stats[e_stats.in_players_team]){
			if ( a_stats[e_stats.hp_current] > 0){
				if ( (a_stats[e_stats.hp_current] / a_stats[e_stats.hp_max]) < 0.75) ds_list_add(injured, id);
			}
		}
	}
	show_debug_message("injured size: " + string(ds_list_size(injured)));
	//If there's no injured, it's pointless to do the rest of the healing code
	if (ds_list_size(injured) > 0){
	
	#region MAKE A QUEUE OF HEALING ITEMS, WITH THE MOST POTENT HAVING THE HIGHEST PRIORITY
	
		var healing_items = ds_priority_create();
	
		//Check every list stored inside battle_menu_lists
		for (var i = 0; i < ds_list_size(battle_lists); i ++){
			var action_list = battle_lists[| i];
			//Check every time inside each list
			for (var j = 0; j < ds_list_size(action_list); j ++){
				var item = action_list[| j];
			
				if (item != undefined){
			
					//If the item affects HP, and it HEALS rather than damages AND the current_actor has enough MP to cast it, add it
					if (global.items[# item, e_item_stats.stat_affected] == e_stats.hp_current) &&
					   (global.items[# item, e_item_stats.value_affected] > 0) &&
					   (global.items[# item, e_item_stats.mana_cost] <= ca.a_stats[e_stats.mp_current]){
				  
						 ds_priority_add(healing_items, item, global.items[# item, e_item_stats.value_affected]);
				  
					}
			
				}
			}
		}
	
		show_debug_message("healing_items size: " + string(ds_priority_size(healing_items)));
	#endregion
	
		//If there are no healing items, it's pointless to continue the healing code!
		var total_healing_items = ds_priority_size(healing_items);
	
		if (total_healing_items > 0){
		
			var can_make_action = scr_target_in_range(ca, healing_items, injured, 4); 
			if can_make_action return ai_action_queue;
		
		}//If there are no healing items, this whole code block will be skipped
	}

#endregion

#region ATTACK

	show_debug_message("attack region of scr_AI_actions");

#region ADD OFFENSIVE ITEMS TO THE QUEUE, BASED ON DAMAGE

	var offensive_items = ds_priority_create();
	
	//Check every list stored inside battle_menu_lists
	for (var i = 0; i < ds_list_size(battle_lists); i ++){
		var action_list = battle_lists[| i];
		//Check every time inside each list
		for (var j = 0; j < ds_list_size(action_list); j ++){
			var item = action_list[| j];
		
			//If the item is not undefined and it's a damaging item, add it - this will add items that damage stats other than HP as well, if you have those
			var value_affected = real(global.items[# item, e_item_stats.value_affected]);
		
			if (item != undefined && value_affected < 0){
				//Add priority as the ABSolute value, so the most damaging is the LAST or MAX in the queue
				ds_priority_add(offensive_items, item, abs(value_affected) );
				show_debug_message(global.items[# item, e_item_stats.name] + " added to offensive_items queue");
			}
		}
	}

#endregion
	show_debug_message("offensive_items size: " + string(ds_priority_size(offensive_items)));

	if (ds_priority_size(offensive_items) > 0){
	
		//var enemies = ds_list_create();
	
		with obj_actor{
			if (a_stats[e_stats.in_players_team] != ca.a_stats[e_stats.in_players_team]){
				if (a_stats[e_stats.hp_current] > 0){
					show_debug_message("Enemy added: " + a_stats[e_stats.name]);
					ds_list_add(enemies, id);	
				}
			}
		}
	
		if (ds_list_size(enemies) > 0){
			show_debug_message("enemies list size: " + string(ds_list_size(enemies)));
			var can_make_action = scr_target_in_range(ca, offensive_items, enemies, 4); 
			if can_make_action return ai_action_queue;
		}
	}

#endregion

#region MOVE TOWARDS NEAREST ENEMY

	//If the script makes it this far, this should mean that there is nobody to heal or attack in range
	//or the actor is unable to do so because of movement or lack of healing/attack items
			
#region FIND NEAREST (PROBABLE) ENEMY
			
	//Would be much better to have a queue that's created during scr_display_action_nodes that contains the ACTUAL
	//closest enemies, based on path rather than cell coordinates

	ds_list_destroy(enemies);
	var enemies = ds_priority_create();
	var target = noone;
			
	with obj_actor{
		if (a_stats[e_stats.in_players_team] != ca.a_stats[e_stats.in_players_team]){
			if (a_stats[e_stats.hp_current] > 0){
				var distance = ( abs(grid_x - ca.grid_x) + abs(grid_y - ca.grid_y) );	
				ds_priority_add(enemies, id, distance);
			}
		}
	}
	show_debug_message("ADDED ENEMIES TO A QUEUE TO FIND THE CLOSEST ENEMY");
	target = ds_priority_delete_min(enemies);
	ds_priority_destroy(enemies);
			
#endregion

	if (target != noone){
			
	#region CREATE A PATH THAT LEADS FROM THE CURRENT_ACTOR TO THE TARGET, DONT WORRY ABOUT MOVEMENT POINTS
		show_debug_message("target: " + string(target) + " | target grid_x/grid_y: " + string(target.grid_x) + "/" + string(target.grid_y));
		//on the more nodes we check, the laggier the game can get, but 100 range seems to run fine
		var start_node = obj_scene.node_grid[# ca.grid_x, ca.grid_y];
		var end_node = noone;
		var dsp = ds_priority_create(); //This will hold our target node as the min priority
		//var end_node = obj_scene.node_grid[# target.grid_x, target.grid_y];									<=== COMMENTED OUT EPISODE 24
						
		scr_display_action_nodes(start_node, 1, movement_points, false, 1, true, obj_scene.list_of_active_nodes); //<=== UPDATED EPISODE 24
	
	#region find the node that's closest to the target that we can already move to								<=== NEW EPISODE 24
	
		for (var i = 0; i < ds_list_size(obj_scene.list_of_active_nodes); i ++){							
			var node = obj_scene.list_of_active_nodes[| i];
			var node_score = abs(node.grid_x - target.grid_x) + abs(node.grid_y - target.grid_y);
			ds_priority_add(dsp, node, node_score);
		}
	
		if (ds_priority_size(dsp) > 0) end_node = ds_priority_delete_min(dsp);
		ds_priority_destroy(dsp);
	
	#endregion
	
		scr_generate_path(start_node, end_node, obj_scene.path_queue);
	
	#region DEBUG
		/*
		var debug_p = ds_priority_create();
		ds_priority_copy(debug_p, obj_scene.path_queue);
	
		show_debug_message("ca grid_x/y: " + string(ca.grid_x) + "/" + string(ca.grid_y) + " | actor_grid for this cell: " + string(actor_grid[# ca.grid_x, ca.grid_y]) );
	
		for (var i = 0; i < ds_priority_size(obj_scene.path_queue); i ++){
			var str = ds_priority_delete_max(debug_p);
			show_debug_message(string(str) + " is a node in the path_queue. Grid_x/y: " + string(str.grid_x) + "/" + string(str.grid_y) + " | actor_grid for this cell: " + string(actor_grid[# str.grid_x, str.grid_y]) );
			var actor = actor_grid[# str.grid_x, str.grid_y];
			if (actor != noone) && (actor_grid[# str.grid_x, str.grid_y] != ca) show_debug_message("Actors grid_x/y: " + string(actor.grid_x) + "/" + string(actor.grid_y));
		}
		*/
	#endregion
			
	#endregion
						
		//Now we want to limit the path by the actor's movement range
		while (ds_priority_size(obj_scene.path_queue) > (movement_points + 1)){
			var node = ds_priority_delete_min(obj_scene.path_queue);	
			show_debug_message("path point deleted: " + string(node) + " | grid_x/y: " + string(node.grid_x) + "/" + string(node.grid_y));
		}
						
	#region MAKE THE ACTOR MOVE
			
		with ca{														
			moving = true;																	
			has_moved = true;
			target_node = scr_get_next_path_node(obj_scene.path_queue);
		}
										
		//Remove actor id from its grid position in actor_grid				
		actor_grid[# ca.grid_x, ca.grid_y] = noone;	
		obj_scene.current_action = e_battle_menu.move;
		with obj_AI_manager state = e_actions.wait_for_animation_end;
						
		obj_AI_manager.target = target;

	return ai_action_queue;
			
#endregion
	
	}

#endregion


}
