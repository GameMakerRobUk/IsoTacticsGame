/// @function scr_levelup(current_actor)
/// @description Add stats to the current actor
/// @param {real} current_actor - instance_id of the current_actor
function scr_levelup(ca) {

	var class = ca.a_stats[e_stats.class];

	//Go through each stat and get the min/max for that stat to be increased
	for (var i = 0; i < ds_grid_width(global.levelup_stats); i ++){

		var data = global.levelup_stats[# i, class];

		if (data != undefined){
		
		#region FIND THE MIN/MAX FOR EACH STAT
		
			var min_val = "";
			var max_val = "";
			var state = 0;
			//data = "10,20,"
			for (var j = 1; j <= string_length(data); j ++){
				var char = string_char_at(data, j);
				var is_digit = string_digits(char);

				if (string_length(is_digit) > 0){
					if (state == 0) min_val += char; else if (state == 1) max_val += char;	
				}else{
					if (char == ","){
						state ++;	
					}
					if (state == 2) break; //The 2nd comma should be after all the numbers
				}
			}
		
		#endregion
		
			if (min_val != "") && (max_val != ""){
		
			#region ADD THE MIN/MAX TO THE STAT
		
				min_val = string_digits(min_val);
				max_val = string_digits(max_val);
			
				var stat_gain = irandom_range( real(min_val), real(max_val) );
				ca.a_stats[i] += stat_gain;
			
				show_debug_message(global.character_stats[# i, 0] + " increased by " + string(stat_gain));
		
			#endregion
		
			}
		
		}
	
	}


}
