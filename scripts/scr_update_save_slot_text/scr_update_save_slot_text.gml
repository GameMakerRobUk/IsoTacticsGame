function scr_update_save_slot_text(){
	for (var i = 0; i < 3; i ++){
	
		var fname = "tactics_save_" + string(i) + ".txt";
		//show_debug_message(fname);
	
		if (file_exists(fname)){
			//show_debug_message(fname + " exists");
			var file = file_text_open_read(working_directory + fname);
			var date = file_text_read_string(file);
		
			save_slot_dates[i] = date;
		
			file_text_close(file);
		
		}else save_slot_dates[i] = "NO DATA";
	}
}