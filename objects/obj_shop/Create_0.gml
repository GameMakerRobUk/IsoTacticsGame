enum e_shop_states{	
	display_buy_sell,		
	display_items_units,			
	buy,						
	sell,							
	items,
	units,
}

//How much are items worth when selling ( based on their "cost" entry in global.items eg a "cost" of 10 would sell for 5 at a price_sell_modifier of 0.5 )

price_sell_modifier = 0.5;												

heading_text[e_shop_states.display_buy_sell] = "SHOP";				
heading_text[e_shop_states.display_items_units] = "SHOP";
heading_text[e_shop_states.buy] = "BUY";
heading_text[e_shop_states.sell] = "SELL ITEMS";
heading_text[e_shop_states.items] = "BUY ITEMS";
heading_text[e_shop_states.units] = "RECRUIT UNITS";

state = e_shop_states.display_buy_sell; 
selected_option = e_shop_states.buy;		

a_text[e_shop_states.buy] = "BUY";			
a_text[e_shop_states.sell] = "SELL";		
a_text[e_shop_states.items] = "ITEMS";
a_text[e_shop_states.units] = "UNITS";

list_of_units = ds_list_create();
list_of_items = ds_list_create();
list_of_inventory = ds_list_create();	

ds_list_add(list_of_units, e_characters.fighter, e_characters.archer);
ds_list_add(list_of_items, e_items.axe, e_items.short_bow, e_items.leather_chest);