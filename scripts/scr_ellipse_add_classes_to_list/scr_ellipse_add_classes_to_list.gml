/// @function scr_ellipse_add_classes_to_list(list_of_classes, starting_class)
/// @description setup the variables for drawing the units in a radial manner
/// @param list_of_classes {real} the list that holds the indexes of units that we want to draw
/// @param starting_class {real} the current class of the current selected unit

function scr_ellipse_add_classes_to_list(list_of_classes, starting_class){
	//Sort the list of classes into ascending order (fighter first)
	ds_list_sort(list_of_classes, true); 
	
	var total_classes = ds_list_size(list_of_classes);
	
	//create a temporary list to hold the order of classes that we want
	var temp_list = ds_list_create();
	
	var counter = starting_class;
	var last_class = list_of_classes[| total_classes - 1];
	
	while ds_list_size(temp_list) < total_classes{
		ds_list_add(temp_list, counter);
		
		counter ++;
		
		//If counter went past the last class, set the counter to the first class
		if (counter > last_class ) counter = (e_characters.leave_empty + 1);
	}
	
	//Copy the temp_list over to the class list
	ds_list_copy(list_of_classes, temp_list);
	
	//destroy the temp list
	ds_list_destroy(temp_list);
}