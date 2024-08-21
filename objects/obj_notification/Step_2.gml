//If the player presses ENTER before the timer is done, the instance will destroy itself when timer == wait_time
if keyboard_check_pressed(vk_enter){
	show_debug_message("obj_notification - pressed enter");
	destroy = true;	
}

timer ++;

if (timer >= wait_time && destroy){
	show_debug_message("gold: " + string(gold));
	show_debug_message("destroying obj_notification");
	
	obj_player.state = e_player_states.idle; //let player act again
	instance_destroy();
}