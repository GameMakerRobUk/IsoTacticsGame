//GO TO NEXT ENTRY OF CONVERSATION								

if (state == e_misc_states.conversation){						

	#region CONVERSATION																	
	
	if (keyboard_check_pressed(vk_enter) ){
		if (conversation_entry + 1) < ds_grid_height(conversation){
			conversation_entry ++;
			text = conversation[# 0, conversation_entry];
			speaker = real(string_digits(text));
		
			//Remove digits from string											
			scr_remove_digits();

			unit = scr_center_on_speaker(speaker, ds_terrain_data);
			unit_name = global.character_stats[# e_stats.name, unit];
			show_debug_message("unit_name obj_scene end_step line 18: " + string(unit_name));
		}else{
			
			//If it's not a battle, we're done with obj_scene, otherwise we wanna fight!
			if (map_type_ != e_map_types.battle) state = e_misc_states.done;
			else{
				state = e_misc_states.in_battle;													
				var anim = instance_create_layer(0, 0, layer, obj_animation);						
				anim.state = e_animations.battle_intro;	
				
				//debug
				show_debug_message("ds_list_size(global.char_sprite_grids): " + string(ds_list_size(global.char_sprite_grids)) );
				show_debug_message("e_characters.last: " + string(e_characters.last) );
				
				for (var i = 0; i < ds_list_size(global.char_sprite_grids); i ++){
					show_debug_message("global.char_sprite_grids[| i]: " + string(global.char_sprite_grids[| i]) );
				}
				
				#region CREATE ACTORS AND ADD THEM TO ACTOR_GRID								
				
				for (var yy = 0; yy < ds_grid_height(ds_terrain_data); yy ++){
					for (var xx = 0; xx < ds_grid_width(ds_terrain_data); xx ++){
						
						var list = ds_terrain_data[# xx, yy];
						
						var unit = list[| e_tile_data.unit];															
				
						if (unit > e_characters.leave_empty){
				
							#region Create an instance for this unit												
						
							var actor = instance_create_layer(xx * GRID_SIZE, yy * GRID_SIZE, layer, obj_actor);
							with actor{
								facing = list[| e_tile_data.unit_facing];
								actor_id = list[| e_tile_data.unit];
								ai_controlled = list[| e_tile_data.is_ai_controlled];
								
								#region DEBUG
								//var str = "Number of frames in state for " + string(global.character_stats[# e_stats.name, actor_id]) + ": ";
	
								//for (var i = e_actor_sprites.idle; i < e_actor_sprites.last; i ++) str += string ( sprite_get_number( sprite_grid[# i, 0] ) ) + " | "; show_message(str);
								#endregion
	
								#region Create Stats / Inventory array for each actor		
						
								for (var stats = 0; stats < e_stats.last; stats ++){
									if (stats != e_stats.name) a_stats[stats] = real(global.character_stats[# stats, actor_id]);
									else a_stats[stats] = global.character_stats[# stats, actor_id];
								}
						
								#region UPDATE STATS WITH PASSIVE ITEMS															
						
								if (a_stats[e_stats.accessory] != e_items.empty){
									var item = a_stats[e_stats.accessory];
									var stat_affected = global.items[# item, e_item_stats.stat_affected];
									var value_added = global.items[# item, e_item_stats.value_affected];
							
									a_stats[stat_affected] += value_added;
								}
						
								#endregion
						
								#endregion
							
								#region SET SPRITE GRID	
								//If a character is a special character, use unit, otherwise use class
								if (global.character_stats[# e_stats.is_special_character, actor_id] == "1") sprite_grid = global.char_sprite_grids[| actor_id];
								else{
									sprite_grid = global.char_sprite_grids[| a_stats[e_stats.class] ];
								}
								//show_debug_message("facing: " + string(facing) + " | actor_id: " + string(actor_id) + " | sprite_grid: " + string(sprite_grid) );
								sprite_index = sprite_grid[# e_actor_sprites.idle, facing];
								
								#endregion
							}
					
							actor_grid[# xx, yy] = actor;
					
							#endregion
					
						}else actor_grid[# xx, yy] = noone;
					}
				}
				
				#endregion
			}
			
			if (state == e_misc_states.done){
				//LEAVE CURRENT MAP IF PRESSED ENTER AND CONVERSATION IS DONE		
				scr_rewards();													
			
			}
		}
	}
	
	#endregion

}else{

	if (state == e_misc_states.setup_battle){	
		
		#region SETUP BATTLE																			
		
		#region Clear the reserve list and then add all the available reserve to the list		
		
		ds_list_clear(reserve_list);
		
		for (var i = 0; i < ds_grid_height(global.character_stats); i ++){
			var player_unit = global.character_stats[# e_stats.in_players_team, i];
			
			if (player_unit == 1) ds_list_add(reserve_list, i);
		}
		
		#endregion
	
		//Clear Lists
		ds_list_clear(spawn_tile_list);
		ds_list_clear(mandatory_list);	
		ds_list_clear(turn_list);
		
		//Clear the grids - they could hold out-of-date info otherwise!				
		ds_grid_clear(node_grid, 0);
		ds_grid_clear(actor_grid, 0);													
		ds_grid_clear(anim_grid, 0);
		
		#region Get rid of existing nodes																			
		
		with (obj_node){
			ds_list_destroy(neighbours_list);	//destroy its list
			instance_destroy();
		}
		
		#endregion
		
		//Resize node/actor grid/spell grid														
		ds_grid_resize(node_grid, ds_grid_width(ds_terrain_data), ds_grid_height(ds_terrain_data) );					
		ds_grid_resize(actor_grid, ds_grid_width(ds_terrain_data), ds_grid_height(ds_terrain_data) );			
		ds_grid_resize(anim_grid, ds_grid_width(ds_terrain_data), ds_grid_height(ds_terrain_data) );		
				
		for (var yy = 0; yy < ds_grid_height(ds_terrain_data); yy ++){
			for (var xx = 0; xx < ds_grid_width(ds_terrain_data); xx ++){
				var list = ds_terrain_data[# xx, yy];
			
				if (list[| e_tile_data.spawn_tile] == 0){
					
					#region SETUP PRE BATTLE SPAWN TILES AND UNITS														
					
					ds_list_add(spawn_tile_list, list);						
																							
					var unit = list[| e_tile_data.unit];
					
					//If it's a unit, remove it from the reserve_list						
					if ( unit > e_characters.leave_empty ){							
						var pos = ds_list_find_index(reserve_list, unit);                 
						ds_list_delete(reserve_list, pos);									
						
						//If it's a mandatory unit, add it to the mandatory list			
						if (list[| e_tile_data.must_survive_this_battle] == 1) ds_list_add(mandatory_list, unit);
					}
					
					#endregion
					
				}
		
				#region CREATE NODES										
						
				var node = instance_create_layer(xx * GRID_SIZE, yy * GRID_SIZE, layer, obj_node);
				
				with node{																					
					grid_x = xx;																			
					grid_y = yy;																			
												
					height = list[| e_tile_data.height];													
					parent = noone;																			
					
					//Tell the node it's impassable if it's a water tile or a chasm
					if (list[| e_tile_data.floor_index] == 3 || list[| e_tile_data.height] == 0)			
						passable = false; else passable = true;												
				}

				//Add node to node grid
				node_grid[# xx, yy] = node;
		
				#endregion
			
				//Set cells of anim_grid to noone
				anim_grid[# xx, yy] = noone;
			}
		}	
		show_debug_message("actors have been added to grid and state is now choose units");
		state = e_misc_states.choose_units;
	
		#endregion
		
		#region FILL NODE NEIGHBOUR LISTS - this is how nodes know which other nodes are adjacent to them																			
		
		//Now that we have created all of the nodes, we need to go through the grid and add the relevant nodes to each other
		for (var yy = 0; yy < ds_grid_height(node_grid); yy ++){
			for (var xx = 0; xx < ds_grid_width(node_grid); xx ++){
				var node = node_grid[# xx, yy];

				var list = ds_list_create();
				
				//If the current node is not at an edge, add the node that's between it and the edge we're checking
				if (xx > 0) ds_list_add(list, node_grid[# xx - 1, yy]);
				if (yy > 0) ds_list_add(list, node_grid[# xx, yy - 1]);
				if (xx + 1) < ds_grid_width(node_grid) ds_list_add(list, node_grid[# xx + 1, yy]);
				if (yy + 1) < ds_grid_height(node_grid) ds_list_add(list, node_grid[# xx, yy + 1]);
				
				node.neighbours_list = list;
			}
		}
		
		#endregion
	
	}else{
		
		if (state == e_misc_states.choose_units){
			
			show_debug_message("choose units state");
			
			#region CHOOSE UNITS / GO TO CONVERSATION											
			
			var list_size = ds_list_size(spawn_tile_list) - 1;
			
			//Cycle between spawn spots
			if (keyboard_check_pressed(vk_right) || keyboard_check_pressed(vk_left) ) selected_option = scr_change_option(selected_option, 0, list_size, 1);
			if (keyboard_check_pressed(vk_up) || keyboard_check_pressed(vk_down) ) selected_option = scr_change_option(selected_option, 0, list_size, ceil(list_size / 2) );
			
			//Add/Swap Units
			if (keyboard_check_pressed(vk_enter) ){
				show_debug_message("Pressed enter from choose_units state");
				
				#region PRESS ENTER				
				
				//Do we already have a selected_tile?
				if (prev_selected_option != -1){
					ds_list_copy( temp_list, spawn_tile_list[| selected_option] ); //Store the list of the tile we're about to overwrite
					ds_list_copy( spawn_tile_list[| selected_option], spawn_tile_list[| prev_selected_option] ); //overwrite the tile with the previous list
					ds_list_copy( spawn_tile_list[| prev_selected_option], temp_list); //overwrite previous data with unit_on_tile
					
					//Reset prev_selected_option
					prev_selected_option = -1;
				}else{
					//If the tile is empty, show characters that can be placed there
					var list = spawn_tile_list[| selected_option];
					var unit = list[| e_tile_data.unit];
					
					if (unit <= e_characters.leave_empty){
						
						//If there are no units in reserve, nothing should happen
						if (ds_list_size(reserve_list) > 0){
						
							//Setup the ellipse
							scr_ellipse_setup(reserve_list, draw_queue);		
						
							state = e_misc_states.display_reserve;
							prev_selected_option = selected_option; //Store where selected option was before choosing a unit to place
							selected_option = 0; //We'll used selected_option to cycle between units that can be added to the army
						
						}
					}else prev_selected_option = selected_option; //tile is not empty so we're moving a unit
				}
				
				#endregion
				
			}
			
			//Remove Units
			if (keyboard_check_pressed(vk_backspace) ){
				
				#region REMOVE UNITS											
				
				var list = spawn_tile_list[| selected_option];
				var unit_to_remove = list[| e_tile_data.unit];
				if (unit_to_remove > e_characters.leave_empty){
					//There's a unit, check if it's mandatory, and if not, remove it
					if (ds_list_find_index(mandatory_list, unit_to_remove) == -1){
						//Add unit to reserve troops
						ds_list_add(reserve_list, unit_to_remove);	
						//Clear tile
						list[| e_tile_data.unit] = e_characters.leave_empty;
						list[| e_tile_data.must_survive_this_battle] = 0;
						
						scr_ellipse_setup(reserve_list, draw_queue)				
					}
				}
				
				#endregion
				
			}
			
			if keyboard_check_pressed(vk_space){
			
				#region START BATTLE/CONVERSATION								

				//Center camera on first speaker (in case they moved)
				unit = scr_center_on_speaker(speaker, ds_terrain_data);
				unit_name = global.character_stats[# e_stats.name, unit];
					
				//Start the conversation
				state = e_misc_states.conversation;	
				
				#endregion
				
			}
			
			#endregion
			
		}else{
			
			if (state == e_misc_states.display_reserve){
				
				#region ADD FROM RESERVE								
				
				show_debug_message("display reserve state");
				
				if ( ( keyboard_check_pressed(vk_right) || keyboard_check_pressed(vk_left) ) && finished_rotating){	
					
					show_debug_message("PRESSED LEFT OR RIGHT IN DISPLAY RESERVES")
					selected_option = scr_change_option(selected_option, 0, ds_list_size(reserve_list) - 1, 1);

					finished_rotating = false;								
					
					if (keyboard_check_pressed(vk_left) ) wanted_angle = (start_angle - angle_diff);
					else if (keyboard_check_pressed(vk_right) ) wanted_angle = (start_angle + angle_diff); 
					
				}
				
				if (start_angle != wanted_angle){					

					#region ROTATE THE UNITS				

					start_angle += ( sign ( wanted_angle - start_angle ) * (angle_diff / 50) );
	
					#endregion
	
				}else{
					finished_rotating = true;							
					//show_debug_message("FINISHED ROTATING");
				}
				
				if (keyboard_check_pressed(vk_enter) && finished_rotating){	
					//Add reserve unit to battle

					var list = spawn_tile_list[| prev_selected_option];
					list[| e_tile_data.unit] = reserve_list[| selected_option];
					list[| e_tile_data.is_ai_controlled] = 0;
					list[| e_tile_data.must_survive_this_battle] = 0;
					list[| e_tile_data.unit_facing] = e_facing.south;
					
					//Remove that unit from reserve list
					ds_list_delete(reserve_list, selected_option);
					
					//UPDATE ELLIPSE
					scr_ellipse_setup(reserve_list, draw_queue);	
					
					//reset Variables
					selected_option = prev_selected_option;
					prev_selected_option = -1;
					state = e_misc_states.choose_units;
					battle_state = e_battle.not_ready;										
				}
				
				#endregion
				
			}else{
			
				if (state == e_misc_states.in_battle){

					#region IN_BATTLE													
					
					if (battle_state == e_battle.setup_turn_order){

						#region SETUP TURN ORDER													
						
						//Add all actors into a turn list
						//with obj_actor ds_list_add(other.turn_list, id);							
						//Don't add dead actors to the list
						with obj_actor if state != e_actor_sprites.dead ds_list_add(other.turn_list, id); 
						
						//shuffle the list
						ds_list_shuffle(turn_list);
						
						battle_state = e_battle.next_actor;
						
						#endregion
						
					}
					
					if (battle_state == e_battle.next_actor){
		
						#region CHECK FOR VICTORY / DEFEAT					
						
						if (battle_state != e_battle.defeat){
							//Check to see if one side or another has been defeated
							var player = ds_list_create();
							var enemy = ds_list_create();
							
							//Add actors to either player or enemy list
							with (obj_actor){
								if (state != e_actor_sprites.dead){
									if (a_stats[e_stats.in_players_team]) ds_list_add(player, id);
									else ds_list_add(enemy, id);
								}
							}
							
							//If the lists are empty, that side has been completely destroyed. If all the enemy and player units are dead, player loses.
							if (ds_list_size(enemy) == 0) battle_state = e_battle.victory;
							if (ds_list_size(player) == 0) battle_state = e_battle.defeat;
							
							ds_list_destroy(player);
							ds_list_destroy(enemy);
						}
						
						#endregion
						
						#region NEXT ACTOR																							
						
						//battle_state may have changed because of victory or defeat so we need to check again
						if (battle_state == e_battle.next_actor){			
							
							ds_list_clear(list_of_active_nodes);														
						
							show_debug_message("");
							show_debug_message("-- GETTING NEXT ACTOR ---");
							show_debug_message("");
							if (ds_list_size(turn_list) > 0){
								//Grab next actor
								current_actor = turn_list[| 0];

								show_debug_message("current_actor: " + string(current_actor));
						
								//Delete the actor from the list
								ds_list_delete(turn_list, 0);	
							
								//Center camera on current_actor
								scr_center_on_actor(current_actor);					
							
								//Set grid_x/grid_y to current_actor's grid_x / grid_y			
								grid_x = current_actor.grid_x;
								grid_y = current_actor.grid_y;
							
								//Allow current_actor to move												
								current_actor.has_moved = false;												
							
								if (current_actor.ai_controlled == false){										
									battle_state = e_battle.actor_taking_turn;
								}else{
									battle_state = e_battle.ai_controlled;										
									show_debug_message("AI is in control of this character");
								}
								
								current_action = e_battle_menu.awaiting_action;						
								selected_option = e_battle_menu.move;			
								secondary_option = -1;
							
								//game_set_speed(10, gamespeed_fps); //USED TO SLOW THE GAME DOWN FOR TESTING
							
								//Check what geat this actor has equipped and populate the lists stored inside battle_menu_lists
								#region FILL BATTLE MENU LISTS														
							
								//Clear the lists first
								for (var i = 0; i < ds_list_size(battle_menu_lists); i ++){
									ds_list_clear(battle_menu_lists[| i]);
								}
							
								//Populate the lists - check what's equipped
								for (var i = e_stats.left_hand; i <= e_stats.item_2; i ++){

									var item = current_actor.a_stats[i];										
								
									//Is there something equipped?
									if (item != e_items.empty){

										//Is it a tome?
										if (global.items[# item, e_item_stats.is_tome] == 1){

											//We're going to check all the times to see if this tome gives it as an action - not very efficient!
											for (var j = e_items.empty + 1; j < e_items.last; j ++){
												if (global.items[# j, e_item_stats.which_tome] == item){
													var item_type = global.items[# j, e_item_stats.item_type];
													ds_list_add(battle_menu_lists[| item_type], j);
												}
											}
										}else{
											//Not a tome	
											var item_type = global.items[# item, e_item_stats.item_type];
											ds_list_add(battle_menu_lists[| item_type], item);
										}
									}
							
								}
							
								#endregion
							
							}else battle_state = e_battle.setup_turn_order;
						
						}
						
						#endregion
						
					}else{
						
						if (battle_state == e_battle.ai_controlled){														
							#region AI CONTROLLED UNITS
							
							if (!instance_exists(obj_AI_manager) ){
								
								var ai = instance_create_layer(0,0,layer,obj_AI_manager);
								ai.ai_action_queue = scr_AI_actions(current_actor, battle_menu_lists, 4);	
								
								battle_state = e_battle.running_action;
							}
							
							#endregion
						}																												
					
						if (battle_state == e_battle.actor_taking_turn){					
							
							#region ACTOR TAKING TURN																					
							
							if (current_action == e_battle_menu.awaiting_action){						
								
								#region PICK AN ACTION FROM THE MENU															
								
								if (keyboard_check_pressed(vk_up) || keyboard_check_pressed(vk_down)){
									if (secondary_option == -1){											
										selected_option = scr_change_option(selected_option, e_battle_menu.move, e_battle_menu.item, 1);	
									}else{
										secondary_option = scr_change_option(secondary_option, 0, ds_list_size(battle_menu_lists[| selected_option]) - 1, 1);	
									}
								}
								
								//Don't allow player to switch to secondary menu if there's no available secondary options
								if (ds_list_size(battle_menu_lists[| selected_option]) > 0){				
								
									if (keyboard_check_pressed(vk_right) ){										
										//Show secondary options like Sword / Axe etc	
										if (secondary_option == -1) secondary_option = 0;
									}
								
									if (keyboard_check_pressed(vk_left) && secondary_option != -1){					
										secondary_option = -1;
									}
								
								}																		
								
								if (keyboard_check_pressed(vk_enter) ){
					
									#region AWAITING ACTION AND PRESSED ENTER													
										
									var start_node = node_grid[# current_actor.grid_x, current_actor.grid_y];
										
									if (selected_option == e_battle_menu.move && current_actor.has_moved == false){
										//Show the unit's movement range
										var min_range = 1;																	
										var movement_range = 4; //I don't have a stat for movement for units so setting it her    
										scr_display_action_nodes(start_node, min_range, movement_range, false, 1, true, list_of_active_nodes); 
										current_action = selected_option;	
									}
									
									//Attack / Spell / Item will all work the same way, so we just need to see if it's one of those actions and there was
									//a secondary action selected as well
									if (selected_option == e_battle_menu.attack || selected_option == e_battle_menu.spell || selected_option == e_battle_menu.item)
									    && secondary_option != -1{	
											
										var list = battle_menu_lists[| selected_option];									
										var selected_item = list[| secondary_option];	
											
										//If it's a spell, check for mana														
										var mana_cost = real(global.items[# selected_item, e_item_stats.mana_cost]);				

										if (mana_cost <= current_actor.a_stats[e_stats.mp_current]){								
									
											//Remove mana from current_actor
											current_actor.a_stats[e_stats.mp_current] -= mana_cost;								
											
											//Remove item if it is one-use only			
											scr_remove_if_consumable(current_actor, selected_item);								
											
											var min_range = global.items[# selected_item, e_item_stats.min_range];			
											var max_range = global.items[# selected_item, e_item_stats.max_range];			

											scr_display_action_nodes(start_node, min_range, max_range, true, 1, false, list_of_active_nodes);
											current_action = selected_option;	
										}
									}
										
									#endregion
									
								}
								
								#endregion
								
								#region END TURN															
								
								if (keyboard_check_pressed(vk_backspace) ) battle_state = e_battle.next_actor;
								
								#endregion
								
							}else{																		
													
								if (current_action != e_battle_menu.awaiting_action){			
									
									if (current_action == e_battle_menu.choose_facing){					
										
										#region CHOOSE FACING											
										
										if (keyboard_check_pressed(vk_up) ) current_actor.facing = e_facing.north;
										if (keyboard_check_pressed(vk_right) ) current_actor.facing = e_facing.east;
										if (keyboard_check_pressed(vk_down) ) current_actor.facing = e_facing.south;
										if (keyboard_check_pressed(vk_left) ) current_actor.facing = e_facing.west;
										
										if (keyboard_check_pressed(vk_enter) ) current_action = e_battle_menu.awaiting_action;
										
										#endregion
										
									}else{																
									
										#region TAKING AN ACTION																
									
										#region MOVE THE CURSOR AROUND
											
										if (keyboard_check_pressed(vk_left) || keyboard_check_pressed(vk_right) ) 
											grid_x = scr_change_option(grid_x, 0, ds_grid_width(ds_terrain_data) - 1, 1); 
							
										if (keyboard_check_pressed(vk_up) || keyboard_check_pressed(vk_down) ) 
											grid_y = scr_change_option(grid_y, 0, ds_grid_height(ds_terrain_data) - 1, 1); 
											
										#endregion	
									
										#region PRESSED ENTER AFTER ALREADY CHOOSING A MENU OPTION									
									
										if (keyboard_check_pressed(vk_enter)){
											
											if (current_action == e_battle_menu.move && current_actor.has_moved == false){	 
											
												#region MOVE THE UNIT																
											
												var start_node = node_grid[# current_actor.grid_x, current_actor.grid_y];
												var end_node = node_grid[# grid_x, grid_y];
									
												//Check that the selected node is within range and if so, show path
												if (ds_list_find_index(list_of_active_nodes, end_node) != -1){
													scr_generate_path(start_node, end_node, path_queue);
												
													with current_actor{														
														moving = true;																	
														has_moved = true;
														target_node = scr_get_next_path_node(other.path_queue);
													}
										
													//Remove actor id from its grid position in actor_grid				
													actor_grid[# current_actor.grid_x, current_actor.grid_y] = noone;	
													
												
												}
											
												#endregion
											
											}else{
												if (current_action == e_battle_menu.attack || current_action == e_battle_menu.spell || current_action == e_battle_menu.item){
													
													#region PERFORM ATTACK / SPELL / ITEM													
													
													//Either a weapon, spell or item has been chosen, and they'll all work the same So we can use one code block for it
	
													var list = battle_menu_lists[| selected_option];
													var item = list[| secondary_option];
													var must_target_actor = global.items[# item, e_item_stats.must_target_an_actor];
													
													//Check for "must_target_an_actor"
													if (!must_target_actor) || (must_target_actor && actor_grid[# grid_x, grid_y] != noone){
														//run scr_display_action_nodes to make a list for the AoE
														var start_node = node_grid[# grid_x, grid_y];
														var min_range = 0;
														var max_range = global.items[# item, e_item_stats.aoe_range];
													
														scr_display_action_nodes(start_node, min_range, max_range, true, 1, false, list_of_active_nodes);
														
														#region Work out new facing	for current_actor so they turn towards the target tile				
														
														current_actor.facing = scr_facing(current_actor, grid_x, grid_y);										
	
														#endregion
														
														var animate_the_action = instance_create_depth(0,0,0,obj_animation);					
														animate_the_action.state = e_animations.take_an_action;		
														animate_the_action.item = list[| secondary_option];														
														
														//set the battle state to something else so that no player input will work
														battle_state = e_battle.running_action;													
													}
													
													#endregion
													
												}
											}
										
										}
											
										#endregion	
									
										#region CANCEL ACTION
									
										if (keyboard_check_pressed(vk_backspace) ){
											//Clear the list of active nodes so it's not displaying nodes after cancelling the action
											ds_list_clear(list_of_active_nodes);
											current_action = e_battle_menu.awaiting_action;
										}
									
										#endregion
									
										#endregion
									
									}																	

								}
							
							}
	
							#endregion
							
						}
					
					}
					
					#endregion
					
					#region VICTORY + DEFEAT									
					
					if (battle_state == e_battle.victory || battle_state == e_battle.defeat) && !instance_exists(obj_animation){
						var animation = instance_create_layer(0,0,layer,obj_animation);
						if (battle_state == e_battle.victory) animation.state = e_animations.victory;
						else animation.state = e_animations.defeat;
					}
					
					#endregion
					
				}
			
			}
			
		}
		
	}

}

//KILL ALL THE ENEMIES	!!! TESTING !!!	- ends the battle quickly by killing all the ai units
/*
if keyboard_check_pressed(vk_escape){
	//scr_levelup(current_actor);
	
	with obj_actor{
		if (a_stats[e_stats.in_players_team] != 1) state = e_actor_sprites.dead;
	}
	
}
*/