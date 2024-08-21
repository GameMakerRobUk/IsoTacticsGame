/// @function scr_facing(current_actor, target_grid_x, target_grid_y)
/// @description Change the actor's facing depending on target grid_x/y
/// @param {real} current_actor
/// @param {real} target_grid_x
/// @param {real} target_grid_y
function scr_facing(ca, gx, gy) {

	var x_diff = gx - ca.grid_x;
	var y_diff = gy - ca.grid_y;

	if (abs(y_diff) > abs(x_diff) ){
		if (y_diff > 0) facing = e_facing.south;
		else facing = e_facing.north;
	}else{
		if (x_diff > 0) facing = e_facing.east
		else facing = e_facing.west;
	}

	return facing;


}
