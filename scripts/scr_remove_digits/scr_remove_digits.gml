function scr_remove_digits() {
	//Code will remove numbers from the start of the string until it hits a none-number, then it will break
	for (var i = 1; i < string_length(text); i ++){
		var char = string_char_at(text, 1);								

		if (string_digits(char)	!= "") text = string_delete(text, 1, 1);						
		else break;													
	}


}
