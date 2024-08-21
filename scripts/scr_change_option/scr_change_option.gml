/// @function scr_change_option(current, min, max, increment)									
/// @description Return the new value of a variable after pressing up/down
/// @param {real} current - the current value of the variable we're changing
/// @param {real} min - the minimum value that this variable can be
/// @param {real} max - the maximum value that this variable can be
/// @param {real} increment - the amount to increase or decrease the value by					
function scr_change_option(current_value, min_value, max_value, increment) {

	if keyboard_check_pressed(vk_down) || keyboard_check_pressed(vk_right){
		current_value += increment;																	
	
		if (current_value > max_value){																
			var diff = ( (current_value - max_value) - 1);
			current_value = min_value + diff;
		}
	}
	
	if keyboard_check_pressed(vk_up) || keyboard_check_pressed(vk_left){
		current_value -= increment;																		
	
		if (current_value < min_value){																
			var diff = ( (min_value - current_value) - 1);
			current_value = max_value - diff;
		}
	}

	audio_play_sound(snd_select, 0, false);		
	return(current_value);

}
