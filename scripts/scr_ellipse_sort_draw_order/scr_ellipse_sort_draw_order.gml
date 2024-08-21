/// @function scr_ellipse_sort_draw_order(list_of_units, draw_queue);

function scr_ellipse_sort_draw_order(list_of_units, draw_queue){
	
	var highest_draw_y = 0;
	var min_scale = 0;
	var max_scale = 4;
	
	//We'll have lists that hold the draw data for each unit but we need something to store those lists 
	//before we add them to the queue. (We can't add them to the queue in the first loop because we haven't
	//established highest_draw_y yet
	var temp_list = ds_list_create();
	
	//Work out angle and draw_x/draw_y for each unit
	for (var i = 0; i < ds_list_size(list_of_units); i ++){
		
		var angle = start_angle - (i * angle_diff);
		
		var draw_x = ellipse_draw_x + lengthdir_x(ellipse_width, angle);		
		var draw_y = ellipse_draw_y + lengthdir_y(ellipse_height, angle);		
		
		//Save the highest draw_y
		if (draw_y > highest_draw_y) highest_draw_y = draw_y;
	
		//Make a list and add the arguments/variables we need to draw each unit in place
		var list = ds_list_create();
		ds_list_add(list, list_of_units[| i], draw_x, draw_y, 1, e_facing.south, true, 
		            e_battle_menu.move, 0);
	
		ds_list_add(temp_list, list);
	}
	
	//Assign scale based on units draw_y vs highest draw_y
	for (var i = 0; i < ds_list_size(temp_list); i ++){
		var list = temp_list[| i];
		var units_draw_y = list[| 2];
		
		//y_diff will hold the difference between units_draw_y and highest_draw_y in pixels
		var y_diff = (units_draw_y / highest_draw_y);
		
		//lerp will give us a scaled value based on y_diff and a value between min_scale and max_scale
		var draw_scale = lerp(min_scale, max_scale, y_diff);
		
		list[| 3] = draw_scale;
		
		ds_priority_add(draw_queue, list, units_draw_y);
	}
}