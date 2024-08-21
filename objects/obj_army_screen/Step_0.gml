#region CHANGE OPTION									

if (keyboard_check_pressed(vk_left) || keyboard_check_pressed(vk_right) ){
	
	if (finished_rotating && (state == e_army_states.choose_unit || state == e_army_states.change_class) ){ 
		
		#region CHOOSE UNIT / CHOOSE CLASS							
		
		if (state == e_army_states.choose_unit) selected_unit = scr_change_option(selected_unit, 0, ds_list_size(army_list) - 1, 1); 
		else if (state == e_army_states.change_class) selected_option = scr_change_option(selected_option, e_characters.fighter, e_characters.monk, 1);
		finished_rotating = false;
		
		if (keyboard_check_pressed(vk_left) ) wanted_angle = (start_angle - angle_diff); 
		if (keyboard_check_pressed(vk_right) ) wanted_angle = (start_angle + angle_diff); 
		
		#endregion
		
	}
	
	if (state == e_army_states.change_equipment){			
		
		#region CHANGE EQUIPMENT				
		
		if (show_gear_list == false){
			//We're just choosing an equipment slot
			selected_option = scr_change_option(selected_option, e_stats.left_hand, e_stats.item_2, 1);
		}else{
			//Picking an item from the Army inventory to go in the slot
			selected_option = scr_change_option(selected_option, 0, ds_list_size(gear_list) - 1, 1);
		}
		
		#endregion
		
	}
}
if (keyboard_check_pressed(vk_up) || keyboard_check_pressed(vk_down) ){
	if (state == e_army_states.display_options) selected_option = scr_change_option(selected_option, e_army_states.change_class, e_army_states.fire_unit, 1); 
}

#endregion

if (keyboard_check_pressed(vk_enter) ){
	
	#region PRESS ENTER													
	
	if (state == e_army_states.choose_unit){
		state = e_army_states.display_options;	
		selected_option = e_army_states.change_class;
	}else{
	
		if (state == e_army_states.display_options){
			state = selected_option; //State will now equal either Change Class / Change Gear or Fire Unit	
			
			if (state == e_army_states.change_class){
				//Set selected option to current class of unit
				selected_option = real(global.character_stats[# e_stats.class, army_list[| selected_unit] ]);
				
				//Organise list_of_classes so that the first class is the chosen unit's current class
				scr_ellipse_add_classes_to_list(list_of_classes, selected_option);				
				
				//Setup Ellipse variabls
				scr_ellipse_setup(list_of_classes, units_to_draw);									
				
			//}else selected_option = 0;														
			}else{																					
				if (state == e_army_states.change_equipment) selected_option = e_stats.left_hand;
				else selected_option = 0;													
			}															
			
			if (state == e_army_states.fire_unit){
				
				#region FIRE UNIT											
				
				//Check that it's not a special unit
				if (global.character_stats[# e_stats.is_special_character, army_list[| selected_unit] ] == "0" ){
				
					//Remove Items and add them to inventory - need an inventory before coding this!
				
					//Remove Character from grid and from army list
					for (var xx = 0; xx < e_stats.last; xx ++) global.character_stats[# xx, army_list[| selected_unit] ] = "-1";
					ds_list_delete(army_list, selected_unit);
				
					//Make sure selected_unit is not larger than the size of the list
					selected_unit = clamp(selected_unit, 0, ds_list_size(army_list) - 1);
				
					#region Recalculate angle_difference					
					
					scr_ellipse_setup(army_list, units_to_draw);
					
					//Reset Selected_unit
					selected_unit = 0;
					
					#endregion
				
					//Set State
					state = e_army_states.choose_unit;
					selected_option = selected_unit;
				
				}else{
					//The character is special
					state = e_army_states.display_options;	
					selected_option = e_army_states.fire_unit;
				}
				
				#endregion
				
			}
		}else{
			if (state == e_army_states.change_class){
				
				#region Change units class								
				
				#region CAN CHARACTER ACTUALLY CHANGE TO THIS CLASS? (based on stats) 
				var can_change_class = true;
				
				//Check each of the stats of the unit vs the requirements
				for (var stat = e_stats.strength; stat <= e_stats.agility; stat ++){
					var unit_stat = real ( global.character_stats[# stat, army_list[| selected_unit] ] );
					var class_stat_req = real ( global.class_req[# stat, selected_option] );
					
					if (unit_stat < class_stat_req){
						can_change_class = false;
						
						show_debug_message("Class: " + global.character_stats[# e_stats.name, selected_option]);
						show_debug_message("stat: " + global.character_stats[# stat, 0]);
						show_debug_message("Unit's value: " + string(unit_stat) );
						show_debug_message("Class Req: " + string(class_stat_req) );
						break;
					}
				}
				
				#endregion
				
				if (can_change_class){					
				
					var unit_entry = army_list[| selected_unit];
					//Change Class
					global.character_stats[# e_stats.class, unit_entry ]
						= string(selected_option);
					//Change Name (only if not a special character)
					if (global.character_stats[# e_stats.is_special_character, unit_entry ] == "0")
						global.character_stats[# e_stats.name, unit_entry ] 
							= global.character_stats[# e_stats.name, selected_option ];
					#region UNEQUIP INAPPROPRIATE GEAR FOR THIS CLASS	
				
					var start_ = e_stats.left_hand;
					var end_ = e_stats.item_2;
				
					for (var i = start_; i <= end_; i ++){

						var item = real(global.character_stats[# i, army_list[| selected_unit] ]);
					
						if (item != e_items.empty){
					
							var can_be_used_by_this_class = global.items[# item, selected_option];
					
							if (can_be_used_by_this_class == "0"){
								//Add item back inventory
								global.inventory[| item] ++; 
								//Set current slot for Unit to empty eg left_hand
								global.character_stats[# i, army_list[| selected_unit] ] = e_items.empty;
							}	
						}
					}
				
					#endregion
				
					selected_option = e_army_states.change_class;
					state = e_army_states.display_options;
				
				}									
				
				#endregion
				
			}else{
				if (state == e_army_states.change_equipment){	

					if (show_gear_list == false){				

						#region CHANGE EQUIPMENT				
						
						unit_class = global.character_stats[# e_stats.class, army_list[| selected_unit] ]; 
					
						ds_list_clear(gear_list);
						show_gear_list = true;
						
						gear_goes_here = selected_option; 			
						slot_to_equip = global.gear_goes_where[selected_option];
					
						#region Add items to gear_list			
					
						//We will add an empty slot to the gear list so that items can be removed easily											
						ds_list_add(gear_list, e_items.empty);
					
						for (var j = e_items.dagger; j < e_items.last; j ++){
							var quantity = global.inventory[| j];
							var equips_where = global.items[# j, e_item_stats.equip_where];
							//If quantity of item is greater than 0 and this item is equippable by this class, add it to the gear_list
							if (quantity > 0 && equips_where == slot_to_equip && global.items[# j, unit_class] == "1"){
								ds_list_add(gear_list, j);
							}
						}
						
						selected_option = 0;					
					
						#endregion
					
						//If the gear list is empty, dont show it
						if (ds_list_size(gear_list) == 0){
							show_gear_list = false;	
							selected_option = e_stats.left_hand;
						}
					
						#endregion
					
					}else{
						#region ADDING GEAR TO A SLOT			
						
						//Check for previous equipment
						var current_item_in_slot = real(global.character_stats[# gear_goes_here, army_list[| selected_unit] ]);
						
						//show_debug_message("current item in slot: " + global.items[# current_item_in_slot, 0])
						var new_item_to_place = gear_list[| selected_option]; 
						//show_debug_message("new_item_to_place: " + global.items[# new_item_to_place, 0])
						if (current_item_in_slot != e_items.empty ){
							//Slot isn't empty
							global.inventory[| current_item_in_slot] ++; //Add 1 to quantity for that item
						
							if (ds_list_find_index(gear_list, current_item_in_slot) == -1){												
								//This item isn't currently in the list so we'll add it back
								ds_list_add(gear_list, current_item_in_slot);
							
								//Now we'll sort the list
								ds_list_sort(gear_list, true);
							}
						}
					
						//Add new item to slot
						show_debug_message("new_item_to_place: " + string(new_item_to_place) );
						//show_debug_message("item in slot before update: " + string(global.character_stats[# gear_goes_here, army_list[| selected_unit] ]));
						global.character_stats[# gear_goes_here, army_list[| selected_unit] ] = new_item_to_place;
						//show_debug_message("item in slot after update: " + string(global.character_stats[# gear_goes_here, army_list[| selected_unit] ]));
						//Remove new item from inventory
						global.inventory[| new_item_to_place] --;
						
						//If the quantity reaches 0, remove the item from gear list
						if (global.inventory[| new_item_to_place] == 0){
							ds_list_delete(gear_list, selected_option);	
						}
						
						#endregion
					}
				}
			}
		}
	}
	
	#endregion
	
} //PRESSED ENTER

if (keyboard_check_pressed(vk_backspace) ){
	
	#region BACKSPACE												
	
	//GO BACK TO CHOOSE A UNIT
	if (state == e_army_states.display_options){
		state = e_army_states.choose_unit;
		selected_unit = 0;
		selected_option = 0;
		
		//Update ellipse
		scr_ellipse_setup(army_list, units_to_draw);				
	}
	else{
		//EXIT TO WORLD MAP
		if (state == e_army_states.choose_unit){
			obj_player.state = e_player_states.world_menu;
			instance_destroy();
		}else{

			if (state == e_army_states.change_equipment && show_gear_list){
										
				//Clear gear_list											
				ds_list_clear(gear_list);
			
				//reset variables
				show_gear_list = false;								
				selected_option = e_stats.left_hand;				
			}else{
				state = e_army_states.display_options;
				selected_option = e_army_states.change_class;
			}
			
		}
	}
	
	#endregion
	
}

if (start_angle != wanted_angle){			

	#region ROTATE THE UNITS					

	start_angle += ( sign ( wanted_angle - start_angle ) * (angle_diff / 50) );
	
	#endregion
	
}else finished_rotating = true;