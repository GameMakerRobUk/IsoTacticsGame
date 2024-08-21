function scr_rewards(){
	var rewards_gold = global.rewards[# e_rewards.gold, global.ds_values[| e_values_to_track.story_state] ];
	var rewards_items_list = global.rewards[# e_rewards.items, global.ds_values[| e_values_to_track.story_state] ];
	var rewards_units_list = global.rewards[# e_rewards.units, global.ds_values[| e_values_to_track.story_state] ];
	
	//ADD GOLD
	global.ds_values[| e_values_to_track.gold] += rewards_gold;
	
	//ADD ITEMS
	for (var i = 0; i < ds_list_size(rewards_items_list); i ++){
		var item = rewards_items_list[| i];
		//show_debug_message("before - global.inventory[| " + string(item) + "]: " + string(global.inventory[| item]));
		global.inventory[| item] ++;
		//show_debug_message("after - global.inventory[| " + string(item) + "]: " + string(global.inventory[| item]));
	}
	
	//ADD UNITS
	for (var i = 0; i < ds_list_size(rewards_units_list); i ++){
		var unit = rewards_units_list[| i];
		var entry = scr_create_unit(unit, 1, global.character_stats);
		global.character_stats[# e_stats.in_players_team, entry] = 1; 	
	}
	
	var notification = instance_create_layer(0,0,layer,obj_notification);
	
	with notification{
		gold = rewards_gold;
		items_list = rewards_items_list;
		units_list = rewards_units_list;
	}
	
	#region RESET STATES FOR OTHER OBJECTS ETC
	
	global.ds_values[| e_values_to_track.story_state] ++;
	obj_scene.show_map = false;
	camera_set_view_pos(view_camera[0], 0, 0);
				
	//Set state to idle
	obj_scene.state = e_misc_states.idle;	
	obj_scene.battle_state = e_battle.not_ready;
		
	//SET PLAYER STATE TO IDLE																
	obj_player.state = e_player_states.rewards;
				
	//Get rid of actor objects
	with obj_actor instance_destroy();
	
	#endregion
}