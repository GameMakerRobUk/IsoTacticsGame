if (state == e_misc_states.conversation || state == e_misc_states.in_battle){

	#region DRAW BLACK RECTANGLE TO HIDE THE OTHER STUFF										
	
	x1 = -display_get_width();																	
	y1 = -display_get_height();																	
	x2 = x1 + display_get_width() * 3;															
	y2 = y1 + display_get_height() * 3;															
	
	draw_set_colour(c_black);
	draw_rectangle(x1, y1, x2, y2, false);
	draw_set_colour(c_white);
	
	#endregion
	
	draw_set_font(fnt_editor);

	for (var yy = 0; yy < ds_grid_height(ds_terrain_data); yy ++){							
		for (var xx = 0; xx < ds_grid_width(ds_terrain_data); xx ++){                        
		
			#region DRAW CELL														
		
			list = ds_terrain_data[# xx, yy];												
			floor_ind = list[| e_tile_data.floor_index];        
			height = list[| e_tile_data.height];		
			spawn_tile = list[| e_tile_data.spawn_tile];																															
			unit = list[| e_tile_data.unit];																																
			unit_facing = list[| e_tile_data.unit_facing];																														
			con_index = list[| e_tile_data.conversation_index];																												
		
			draw_x = (xx - yy) * (iso_width / 2);						

			//Draw a tile for EVERY level of the cell, a cell with a height of "3" would mean this loop gets run 4 times (0, 1, 2, 3) per step
			for (var draw_height = 0; draw_height <= height; draw_height ++){
			
				//If we don't want to display all heights, only draw cells UP TO current_height OR draw cells to their proper height if display_all_heights equals true
				if (display_all_heights == false && draw_height <= current_height) || (display_all_heights == true){														
				
					draw_y = (xx + yy) * (iso_height / 2) - (draw_height * (iso_height / 2 ) );					
			
					//We'll make a colour and save it in "col" and use it ti affect the colour of whatever tile is drawn - this will make the different heights clearer
					var rgb_value = 150 + (draw_height * 9);																
					var col = make_color_rgb(rgb_value, rgb_value, rgb_value);												
					draw_sprite_ext(spr_iso_floor, floor_ind, draw_x, draw_y, 1, 1, 0, col, 1);			
					
					if (map_type_ == e_map_types.battle){			
					
						var node = node_grid[# xx, yy];
			
						#region Draw Highlight if this is an active node																	
					
						if (ds_list_find_index(list_of_active_nodes, node) != -1){
							draw_sprite(spr_iso_cell_highlight, 0, draw_x, draw_y);	
						}
					
						#endregion
					
						#region Draw highlight if this node is a path node																				
					
						if (ds_priority_find_priority(path_queue, node) != undefined){
							draw_sprite(spr_iso_cell_highlight, 1, draw_x, draw_y);	
						}
					
						#endregion
					
					}
					
					//Draw deco																												
					if (draw_height == height){
						//Only draw the decoration if we're at the highest tile
						var spr = global.cell_sprites[e_tile_data.decoration_index];
						var index = list[| e_tile_data.decoration_index];
						draw_sprite_ext(spr, index, draw_x, draw_y, 1, 1, 0, col, 1);
					
						#region UNIT																				
						
						if (state == e_misc_states.conversation){						
							ed_col = c_white;	

							//UNIT
							if (unit != undefined && unit >= e_characters.fighter){
								var team = !spawn_tile;
								
								scr_army_screen_draw_unit(unit, draw_x, draw_y, 1, unit_facing, false, e_actor_sprites.idle, obj_player.image_index, team, c_white);
								
							}
						}
					
						#endregion
						
						if (map_type_ == e_map_types.battle){		
						
							#region BATTLE UNIT																				
						
							if (state == e_misc_states.in_battle){
							
								var actor = actor_grid[# xx, yy];
							
								if (actor != noone){
								
									if (actor.state != e_actor_sprites.dead){											
										unit = actor.actor_id;
										facing = actor.facing;
										scr_army_screen_draw_unit(unit, draw_x, draw_y, 1, facing, false, actor.state, actor.image_index, actor.a_stats[e_stats.in_players_team], c_white); 	
								
										//is this the current_actor? Make it obvious									
										if (actor == current_actor){					
											if (current_action == e_battle_menu.choose_facing)
												draw_sprite(spr_iso_choose_facing, current_actor.facing, draw_x, draw_y);
										}
									
										if (actor.a_stats[e_stats.in_players_team] == false) draw_sprite(spr_iso_enemy, 0, draw_x, draw_y); 
									
									}else{																				
										if (actor.sprite_index != -1)												
											draw_sprite(actor.sprite_index, actor.image_index, draw_x, draw_y);		
									}																				
								}
							
								//if (battle_state == e_battle.actor_taking_turn && current_actor != noone && current_actor.moving){							
								if (battle_state >= e_battle.actor_taking_turn && current_actor != noone && current_actor.moving){				
								
									#region DRAW CURRENT ACTOR IF MOVING																			
								
									/*
										We want to show the current_actor moving step by step, so we can't just use grid_x / grid_y (as that would snap
										the unit to a particular cell).
										ca_xx and ca_yy are similar to xx/yy, except ca_xx / ca_yy will often not be a whole number eg 1.234 as opposed to 0/1/2/3
										This is how we get the gradual movement to be drawn
										The Actor is actually moving on a 2D grid, remember, we're just drawing it in ISOMETRIC
									*/
								
									var ca_xx = current_actor.x / GRID_SIZE; 
									var ca_yy = current_actor.y / GRID_SIZE;
								
									if (ceil(ca_xx) == xx && ceil(ca_yy) == yy){
									
										//Work out draw coordinates for the current_actor
										ca_draw_x = (ca_xx - ca_yy) * (iso_width / 2);
										ca_draw_y = (ca_xx + ca_yy) * (iso_height / 2) - (draw_height * (iso_height / 2 ) );		
									
										scr_army_screen_draw_unit(current_actor.actor_id, ca_draw_x, ca_draw_y, 1, current_actor.facing, 
										false, current_actor.state, current_actor.image_index, current_actor.a_stats[e_stats.in_players_team], c_white); 
									
										if (current_actor.a_stats[e_stats.in_players_team] == false) draw_sprite(spr_iso_enemy, 0, ca_draw_x, ca_draw_y);   
										
										//draw_text(draw_x, draw_y - 50, string(current_actor.image_index) + "/" + string(sprite_get_number(current_actor.sprite_index) ) );
									}
								
									#endregion
								
								}
						
							}
						
							#endregion
						
							#region DRAW SPELL ANIMATION																										
						
							node = node_grid[# xx, yy];
						
							if (node.sprite_index == spr_iso_spell_anim){
								draw_sprite(spr_iso_spell_anim, node.image_index, draw_x, draw_y);	
							}
						
							#endregion
					
							#region DRAW obj_anim_stat ANIMATION													
						
							var anim = anim_grid[# xx, yy];
						
							//If there's an instance_id and its variable active is set to true, animate!
							if (anim != noone && anim.active){
							
								draw_set_font(fnt_editor);
								draw_set_halign(fa_center);										
								draw_set_valign(fa_middle);											
							
								//Show effect on stat (damage/healing etc)
								if (anim.state == e_stat_anim.display_action_value){
									var col = c_black;
									if (anim.value > 0) col = c_blue;
									if (anim.value < 0) col = c_red;
							
									//Draw the ABSOLUTE value (turns a negative into a positive)
									if (col != c_black) draw_text_color(draw_x, draw_y - anim.height, string(abs(real(anim.value))), col, col, c_white, c_white, 1);	
									else draw_text_color(draw_x, draw_y - anim.height, "MISS", col, col, c_white, c_white, 1);										
								}else{
									//Show how much xp the actor earned and his current/new level
									if (anim.state == e_stat_anim.display_xp_level){
										var ca_level = current_actor.a_stats[e_stats.level];
										var ca_xp = current_actor.a_stats[e_stats.xp];
										draw_text_color(draw_x, draw_y - 50, "LEVEL " + string(ca_level), c_red, c_red, c_white, c_white, 1);
										draw_text_color(draw_x, draw_y - 30, "XP " + string(ca_xp), c_blue, c_blue, c_white, c_white, 1);
									}
								}
							}
						
							#endregion
					
							#region DRAW CURSOR																								
						
							if (battle_state == e_battle.actor_taking_turn){
								if (xx == grid_x && yy == grid_y)
									draw_sprite(spr_iso_select, 0, draw_x, draw_y);
							}
						
							#endregion
						
						}
						
					}
			
				}
			}          
		
			#endregion
		
		}
	}

}