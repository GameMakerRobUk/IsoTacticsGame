#region CHANGE SELECTED OPTION											

if (state == e_shop_states.display_buy_sell){						
	if ( keyboard_check_pressed(vk_up) || keyboard_check_pressed(vk_down) )
	selected_option = scr_change_option(selected_option, e_shop_states.buy, e_shop_states.sell, 1); 
}

if (state == e_shop_states.display_items_units){					
	if ( keyboard_check_pressed(vk_up) || keyboard_check_pressed(vk_down) )
	selected_option = scr_change_option(selected_option, e_shop_states.items, e_shop_states.units, 1); 
}

if (state == e_shop_states.items){
	if ( keyboard_check_pressed(vk_left) || keyboard_check_pressed(vk_right) )
	selected_option = scr_change_option(selected_option, 0, ds_list_size(list_of_items) - 1, 1);
}

if (state == e_shop_states.units){
	if ( keyboard_check_pressed(vk_left) || keyboard_check_pressed(vk_right) )
	selected_option = scr_change_option(selected_option, 0, ds_list_size(list_of_units) - 1, 1); 
}

if (state == e_shop_states.sell){										
	if ( keyboard_check_pressed(vk_left) || keyboard_check_pressed(vk_right) )
	selected_option = scr_change_option(selected_option, 0, ds_list_size(list_of_inventory) - 1, 1); 
	selected_option = clamp(selected_option, 0, ds_list_size(global.inventory) - 1);
}

#endregion

#region CHOOSE AN OPTION								

if (keyboard_check_pressed(vk_enter) ){

	if (state == e_shop_states.display_items_units){		
		state = selected_option;
		selected_option = 0;
	}else{
		if (state == e_shop_states.items){
			
			var item = list_of_items[| selected_option];							
			
			//Check if the player can afford it [not coded]
			var price = global.items[# item, e_item_stats.cost];						
			if (global.ds_values[| e_values_to_track.gold] >= price){				
			
				//Add item to players inventory
				//var item = list_of_items[| selected_option];
				global.inventory[| item] ++;
				
				//Remove gold
				global.ds_values[| e_values_to_track.gold] -= price;				
			}
		}else{
			if (state == e_shop_states.units){
				//Check if the player can afford it [not coded]
				var unit = list_of_units[| selected_option];
				var price = global.character_stats[# e_stats.cost_to_buy, unit];	
				
				if (global.ds_values[| e_values_to_track.gold] >= price){				
					//Add unit to players army
					//var unit = list_of_units[| selected_option];							
					var entry = scr_create_unit(unit, 1, global.character_stats);
					global.character_stats[# e_stats.in_players_team, entry] = 1; //Set unit to be in players army
					
					//Remove gold
					global.ds_values[| e_values_to_track.gold] -= price;				
				}
			}
		}
	}
	
	if (state == e_shop_states.display_buy_sell){					
		#region DISPLAY BUY / SELL												
		
		if (selected_option == e_shop_states.buy){
			
			state = e_shop_states.display_items_units;
			selected_option = e_shop_states.items;
			
		}else{
			
			state = e_shop_states.sell;
			selected_option = 0;
			ds_list_clear(list_of_inventory);
			//Add items to list_of_inventory								
			for (var i = 1; i < ds_list_size(global.inventory); i ++){
				if (global.inventory[| i] > 0) ds_list_add(list_of_inventory, i);
			}
			
		}
		
		#endregion
	}else{
		if (state == e_shop_states.sell){										
			
			#region SELL													
			
			if (ds_list_size(list_of_inventory) > 0){
			
				//Reduce item by 1 from selling list
				var item = list_of_inventory[| selected_option];
			
				//Reduce item by 1 from global inventory
				global.inventory[| item] --;
			
				//Remove item from selling list if the quantity is <= 0
				if (global.inventory[| item] <= 0){
					ds_list_delete(list_of_inventory, selected_option);
					
					//Clamp selected_option
					selected_option = clamp(selected_option, 0, ds_list_size(list_of_inventory) - 1 );
				}
				
				var price = floor ( real ( global.items[# item, e_item_stats.cost] ) * price_sell_modifier );
				show_debug_message("price of item: " + string ( price ) );
				global.ds_values[| e_values_to_track.gold] += price ;										
				
			}
			
			#endregion 
			
		}
	}
	
}

#endregion

#region GO BACK TO DISPLAY OPTIONS OR EXIT SHOP								

if (keyboard_check_pressed(vk_backspace) ){
	/*
		if in Units/Items, go to Display_items_units
		if in sell or display_items_units, go to display_buy_sell
		if in display_buy_sell exit
	*/
	//Go back to DISPLAY OPTIONS
	if (state == e_shop_states.items || state == e_shop_states.units){
		state = e_shop_states.display_items_units;
		selected_option = e_shop_states.items;
	}else{
		if (state == e_shop_states.sell || state == e_shop_states.display_items_units){
			state = e_shop_states.display_buy_sell;
			selected_option = e_shop_states.buy;
		}else{
			//EXIT SHOP
			obj_player.state = e_player_states.world_menu;
			instance_destroy();
		}
	}
}

#endregion
