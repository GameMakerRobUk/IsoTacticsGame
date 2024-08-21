#region MOVING																		

if (moving){											
	if (target_node != noone){
		
		if (x != target_node.x || y != target_node.y){
			
			//Change Facing of unit - only one of these statements should be true		
			if (x < target_node.x) facing = e_facing.east;
			if (x > target_node.x) facing = e_facing.west;
			if (y > target_node.y) facing = e_facing.north;
			if (y < target_node.y) facing = e_facing.south;
			
			//Move towards target node
			x += sign(target_node.x - x) * UNIT_MOVE_SPEED;
			y += sign(target_node.y - y) * UNIT_MOVE_SPEED;
			
			with obj_scene scr_center_on_actor(other);							
			
		}else target_node = scr_get_next_path_node(obj_scene.path_queue);
	}else{
		
		#region Finished Moving														
		
		moving = false;								
		
		grid_x = floor(x / GRID_SIZE);
		grid_y = floor(y / GRID_SIZE);
		
		//Update Actor grid
		obj_scene.actor_grid[# grid_x, grid_y] = id;	

		//Update current_action and selected_option
		with obj_scene{				
			current_action = e_battle_menu.choose_facing;
			selected_option = e_battle_menu.move;
		}
		
		#endregion
		
	}
}

#endregion