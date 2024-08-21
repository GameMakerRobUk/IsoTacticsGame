/// @function scr_display_action_nodes(start_node, range, impassable_allowed, ignore_tiles_higher_than, actors_block, list_of_active_nodes)
/// @description Generate a list that contains all the nodes that can be used for... movement / attacking etc
/// @param start_node {real} the instance_id of the node that we want to calculate from - can be used to calculate fireball effects as well as move / attack
/// @param min_range {real} the minimum distance from the start_node that we want to check for nodes to add to list											
/// @param max_range {real} the maximum distance from the start_node that we want to check for nodes to add to list
/// @param impassable_allowed {boolean} add impassable nodes? (False would be for a unit that is walking, True would be for a ranged attack)
/// @param ignore_heigher_than {real} Ignore any tiles that are X higher than the current node
/// @param actors_block {boolean} Does the presence of an Actor make this node unusable?
/// @param list_of_active_nodes {real} the index of the list that will store the instance_ids of active nodes
function scr_display_action_nodes(start_node, min_range, max_range, impassable_allowed, ignore_heigher_than, actors_block, list_of_active_nodes) {

#region DISPLAY POSSIBLE MOVES

	var terrain_cost = 1; //All terrain costs 1 but if you want your own game to have variable movement cost based on terrain then give your nodes another variable
						  //and set terrain_cost to it when working out the combined distance

	//Create lists/priority queue
	var dsp_open = ds_priority_create(); //This priority queue holds the id's of nodes we want to check (lowest "combined_distance" will be checked first)
	var ds_added_to_open_already = ds_list_create(); //We use this because its easier for us to check if the node has already been added to open queue

	ds_list_clear(list_of_active_nodes); //Get rid of any nodes that were previously in the list
	show_debug_message("list_of_active_nodes size before adding: " + string(ds_list_size(list_of_active_nodes)));

	//CLEAR NODE DATA
	with obj_node{
		combined_distance = 0;
		parent = noone;
	}

	//Set up variables - set both to 0
	start_node.combined_distance = 0;

	//Add the start node to the priority queue, this is the first node we want to check (we check its list of neighbours)
	ds_priority_add(dsp_open, start_node, start_node.combined_distance);

	var current = noone; //Which node's list are we checking

	//If there are no nodes in the priority queue, we're done
	while (ds_priority_size(dsp_open) > 0){
	
		current = ds_priority_delete_min(dsp_open); //Get the next node from the priority queue
		ds_list_add(ds_added_to_open_already, current); //Add the node to the "already added" list
	
		if (current != undefined){

			//Check currents neighbours to see if they're within max_distance
			var list = current.neighbours_list;
		
			//This loop runs for as many "neighbours" in the current node's list
			for (var i = 0; i < ds_list_size(list); i ++){
				var node = list[| i];
			
				//If this node has already been added to the list, see if current is a better parent
				if (ds_list_find_index(ds_added_to_open_already, node) != -1){
				
					if (current.combined_distance + terrain_cost < node.combined_distance){
						//show_debug_message("BETTER PARENT FOUND");
						node.parent = current;
						node.combined_distance = (current.combined_distance + 1);
					}
				
				}else{
				
					//NODE HAS NOT BEEN ADDED TO OPEN LIST. THIS MEANS IT HASN'T BEEN CHECKED YET

					node.parent = current; //The "Parent" means "where did I come from to get to this new node?" It's used to calculate the shortest path
										   //(Start => Parent => Parent => Parent => End) == the path to follow if moving.
									   
					//If the node is impassable and we're not allowed impassable nodes, just pretend we've already added it				
					if (node.passable == false && impassable_allowed == false)
						ds_list_add(ds_added_to_open_already, node);
				
					//If the node is too high, skip it																					
					if (node.height - ignore_heigher_than) > current.height
						ds_list_add(ds_added_to_open_already, node);
			
					//If Actors are suppsoed to block nodes and there's an actor on this node, skip it								
					if (actors_block && actor_grid[# node.grid_x, node.grid_y] != noone)
						ds_list_add(ds_added_to_open_already, node);
					
					if (ds_list_find_index(ds_added_to_open_already, node) == -1){															
				
						//If this node hasn't already been added to the open queue AND it's in RANGE, add it
						node.combined_distance = (terrain_cost + current.combined_distance); 
						 
						//If the node is within range, add it to the queue and the "already_added" list
					
						//if (node.combined_distance >= min_range && node.combined_distance <= max_range){					
						if (node.combined_distance <= max_range){											//if we don't add nodes that are less than the minimum, we can't check their neighbours
							ds_priority_add(dsp_open, node, node.combined_distance);
							ds_list_add(ds_added_to_open_already, node);
						}
					}
				}
			}
		
			//We only want to add the current if it's within the min/max range (even if it's the start node)
			//show_debug_message("current.combined distance: " + string(current.combined_distance));
			if (current.combined_distance >= min_range && current.combined_distance <= max_range)								
			ds_list_add(list_of_active_nodes, current);
	
		}else break;
	}

	ds_list_destroy(ds_added_to_open_already);
	ds_priority_destroy(dsp_open);

#endregion




}
