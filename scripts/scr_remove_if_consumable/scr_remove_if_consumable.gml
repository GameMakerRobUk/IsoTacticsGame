/// @function scr_remove_if_consumable(current_actor, item_being_used)
/// @description remove the item from the actors inventory if it's a 1-shot use
/// @param {real} current_actor
/// @param {real} item which item is being used
function scr_remove_if_consumable(ca, item) {

	//Remove item if it is one-use only														
	if (global.items[# item, e_item_stats.charges] == 1){
		for (var check = e_stats.left_hand; check <= e_stats.item_2; check ++){
			var item_to_check = ca.a_stats[check];
			if (item_to_check == item) ca.a_stats[check] = e_items.empty;
			break;
		}
	}

}
