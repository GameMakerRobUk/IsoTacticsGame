/// @function scr_center_on_actor(actor)
/// @description Center the map on the actor
/// @param {real} actor - the instance_id of the actor we want to center the camera on
function scr_center_on_actor(actor) {

	cx = ( (actor.x - actor.y) / GRID_SIZE) * (iso_width / 2);												
	cy = ( (actor.x + actor.y) / GRID_SIZE) * (iso_height / 2) - (draw_height * (iso_height / 2 ) );		
			
	camera_set_view_pos(view_camera[0], cx - ( camera_get_view_width(view_camera[0]) / 2 ), cy - ( camera_get_view_height(view_camera[0]) / 2 ) );	
	
}
