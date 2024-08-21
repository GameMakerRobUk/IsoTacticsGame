/// @function scr_action_calculation(current_actor, target, item)
/// @description Calculate the effect on a stat
/// @param {real} current_actor - the instance_id of the actor who is casting a spell/using an item/making an attack etc
/// @param {real} target - instance_id of actor being targetted by effect
/// @param {real} item - the item that's being used eg weapon/spell/consumable
function scr_action_calculation(current_actor, target, item) {

	show_debug_message("Running scr_action_calculation");

	var stat_affected = global.items[# item, e_item_stats.stat_affected];
	var effect_value = real(global.items[# item, e_item_stats.value_affected]);
	var item_type = global.items[# item, e_item_stats.item_type];

	//effect_value will be "added" to a stat in Attacks, and will be a negative number
	if (item_type == e_item_types.attack){
		//Melee/Ranged attacks can miss
		var roll = irandom(99) + 1;
		var hit_chance = current_actor.a_stats[e_stats.accuracy] - target.a_stats[e_stats.agility];
		hit_chance = clamp(hit_chance, 1, 99);
	
		//roll = 100;										// Test for misses by setting Roll to 100					
		if (roll <= hit_chance){ //Hit
		
			/*
				Decided not to use block_melee / block_ranged - adds too much spaghetti code
				and I think we already have enough of that!
			*/
		
			//Add negative strength to effect_value
			effect_value -= current_actor.a_stats[e_stats.strength];
			//Add target defence to effect_value 
			effect_value += target.a_stats[e_stats.defence];
		
		}else effect_value = 0; //Miss
	}

	if (item_type == e_item_types.spell){
	
		//Add intelligence to the value (if effect_value is already negative, makes it MORE negative)
		effect_value += sign(effect_value) * current_actor.a_stats[e_stats.intelligence];
	
		//If it's a damaging spell, target uses wisdom to reduce the effect
		if (effect_value < 0) effect_value += target.a_stats[e_stats.wisdom];
	
		//Check for resistances to spells
		var resist = 0;
	
		//Modify by resistance of target
		if (global.items[# item, e_item_stats.which_tome] == e_items.tome_of_fire){
			var resist = target.a_stats[e_stats.fire_resist];
		}
		if (global.items[# item, e_item_stats.which_tome] == e_items.tome_of_ice){
			var resist = target.a_stats[e_stats.ice_resist];
		}
		var modifier = (100 - resist) / 100;
		if (modifier != 0) effect_value *= modifier;
	}

	//Get rid of decimals
	effect_value = round(effect_value);

	//Clamp effect_value
	if (effect_value != 0){ //value of 0 will count as a "Miss"
		show_debug_message("scr_action_calculation: effect_value before clamping: " + string(effect_value));
		show_debug_message("item: " + string(global.items[# item, e_item_stats.name]));
		if (global.items[# item, e_item_stats.value_affected] < 0) effect_value = clamp(effect_value, -999, -1);
		else effect_value = clamp(effect_value, 1, 999);
	}

	target.a_stats[stat_affected] += effect_value;
	return effect_value;




}
