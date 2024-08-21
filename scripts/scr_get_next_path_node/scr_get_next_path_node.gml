/// @function scr_get_next_path_node(path_queue)
/// @description Get the next node in the path that the actor must travel to
/// @param path_queue (real) the queue that will hold the nodes to travel to
function scr_get_next_path_node(path_queue) {

	if (ds_priority_size(path_queue) > 0){
		
		var next_node = ds_priority_delete_max(path_queue);
		show_debug_message("scr_get_next_path - next_node: " + string(next_node) + " | actor_grid for this node: " + string(obj_scene.actor_grid[# next_node.grid_x, next_node.grid_y]) );
	}else next_node = noone;

	return(next_node);


}
