/// @function scr_generate_path(start_node, end_node, path_queue)
/// @description Generate a path for the actor to move along
/// @param start_node {real} instance_id of the starting node
/// @param end_node {real} instance_id of the node we want to move to
/// @param path_queue (real) the queue that will hold the nodes to travel to
function scr_generate_path(start_node, end_node, path_queue) {

	/*
		We already have a list of nodes that are within range, we only need to check these for the best path
	*/

	show_debug_message("path_queue size before adding: " + string(ds_priority_size(path_queue)));
	//Clear path_queue
	ds_priority_clear(path_queue);

	var current = end_node;
	ds_priority_add(path_queue, end_node, 0); //We'll use lower valued priority first so we can use the size of the queue to determine priority

	while current != start_node{
		var priority = ds_priority_size(path_queue);
	
		if (current.parent != noone){															
			ds_priority_add(path_queue, current.parent, priority);
			current = current.parent;																
		}else{																					
			//If this code runs, there's no path to where the actor is trying to get to, so clear the path queue
			//not clearing it means the actor warps to the target cell
			ds_priority_clear(path_queue);
			break;	
		}
	}



}
