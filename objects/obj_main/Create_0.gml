#region CHARACTER ENUMS + GRID, WORLD ACTION ENUMS							

#region facing

enum e_facing{
	west,
	north,
	east,
	south,
}

#endregion

#region characters

enum e_characters{
	leave_empty,
	fighter,
	archer,
	mage,
	priest,
	warrior,
	knight,
	ranger,
	sniper,
	wizard,
	sorcerer,
	healer,
	monk,
	butz,
	sarah,
	brian,
	davos,
	last,
}

#endregion

#region stats																

enum e_stats{
	name,
	is_special_character,																	
	in_players_team,
	is_ai_controlled,
	must_survive_this_battle,
	class, //e_classes.fighter etc
	kill_this_unit_to_win, //By killing this unit, the battle is won by the player
	hp_max,
	hp_current,
	mp_max,
	mp_current,
	level,
	xp,
	strength,
	intelligence,
	defence,
	wisdom,
	accuracy,
	agility,
	block_chance_melee, //0-100
	block_chance_ranged, //0-100
	fire_resist,
	ice_resist,
	//Gear
	left_hand,     
	right_hand,
	chest,
	accessory,
	item_1,
	item_2,
	cost_to_buy,														
	last,
}

#endregion

#region world actions																							

enum e_world_actions{																										
	army, //Change classes / equip items etc
	save, //Save the game
	load,	//Load the game
	shop, //Enter the shop if this region has one
	last,
}

global.world_action_text[e_world_actions.army] = "Army";
global.world_action_text[e_world_actions.save] = "Save";
global.world_action_text[e_world_actions.load] = "Load";
global.world_action_text[e_world_actions.shop] = "Shop";

#endregion

global.character_stats = load_csv("classes_and_characters.csv");

global.levelup_stats = load_csv("levelup.csv");	

global.class_req = load_csv("class_requirements.csv");							

#endregion

#region SETUP SPRITE ARRAY													

//create an array that stores the sprites we use for the floor/decoration to make it easier to cycle between them
global.cell_sprites[e_tile_data.floor_index] = spr_iso_floor;
global.cell_sprites[e_tile_data.decoration_index] = spr_iso_decoration;

#endregion																	
																						
enum e_actor_sprites{																			
	empty,	
	idle, //This will be the moving animation as well
	attack,
	spell,
	item,
	hurt,
	last,
	dead,																			
}

/*	e_actor_sprites attack/spell/item must be the same numbers are e_battle_menu.attack/spell/item 
    the enum below is a reference

enum e_battle_menu{														
	awaiting_action,
	move,
	attack,
	spell,
	item,
	choose_facing,	
}

*/

#region STATES															

//At what point in the story is the player
enum e_story{																											 
	heading_leave_empty,
	a_debriefing, //1
	the_first_battle,
	the_second_battle,
	the_third_battle,
	last,
}

//What type of map is this going to be?
enum e_map_types{																										
	story_scene,
	battle,
	shop,
	last,
}

enum e_path_point_setup{																							
	map, 
	type_of_map, //USES e_map_types eg story_scene/battle/shop
	conversation_csv, //the conversation to play out during the battle/story scene								
	last,
}

//These values will be saved between games
enum e_values_to_track{																									
	story_state,
	player_x,
	player_y,
	player_sprite,		
	gold,					
	last,
}


global.ds_values = ds_list_create(); //We'll save/load this list between games - every value that we need to track (apart from the players army stuff / battles) will go in this list 

global.ds_values[| e_values_to_track.story_state] = e_story.a_debriefing;
global.ds_values[| e_values_to_track.gold] = 100;														
	
enum e_game_states{
	editing,
	testing,
	game,																																							
}

game_state = e_game_states.game;//e_game_states.editing

#endregion

#region SETUP STORY MAPS/MISSIONS																				

/*
	We have a csv file that holds the map_index (0, 1, 2, 3) and map_type (battle/story scene/shop etc) for each world point for each story state
*/

global.story_points = load_csv("world_path_maps.csv");

#region REWARDS				

enum e_rewards{
	gold,
	items,
	units,
	last,
}

global.rewards = ds_grid_create(e_rewards.last, e_story.last);

//Initialise reward entries
for (var i = 0; i < e_story.last; i ++){
	global.rewards[# e_rewards.gold, i] = 0;	
	global.rewards[# e_rewards.items, i] = ds_list_create();	
	global.rewards[# e_rewards.units, i] = ds_list_create();	
}

//Fill rewards

//A DEBRIEFING - give 500 gold, 2 swords, a tome of healing, a fighter, archer and mage as a reward for completing "A Debriefing" (it's a dialogue-only story point so it's just to give the player something to start with)
global.rewards[# e_rewards.gold, e_story.a_debriefing] = 500;
ds_list_add( global.rewards[# e_rewards.items, e_story.a_debriefing], e_items.sword, e_items.sword, e_items.tome_of_healing );
ds_list_add( global.rewards[# e_rewards.units, e_story.a_debriefing], e_characters.fighter, e_characters.archer, e_characters.mage );

//FIRST BATTLE - give 100 gold, an axe and a tome of fire as a reward for cleaaring the first battle
global.rewards[# e_rewards.gold, e_story.the_first_battle] = 100;
ds_list_add( global.rewards[# e_rewards.items, e_story.the_first_battle], e_items.axe, e_items.tome_of_fire );

//SECOND BATTLE
global.rewards[# e_rewards.gold, e_story.the_second_battle] = 500;
ds_list_add( global.rewards[# e_rewards.units, e_story.the_second_battle], e_characters.knight, e_characters.warrior );

#endregion

#endregion

#region ITEMS / INVENTORY					

enum e_items{
	empty,
	dagger,
	sword,
	short_bow,
	bow,
	staff,
	axe,
	large_shield,
	leather_chest,
	metal_chest,
	ring_of_fire,
	ring_of_ice,
	ring_of_might,
	ring_of_accuracy,
	tome_of_fire,
	tome_of_ice,
	tome_of_healing,
	heal_potion,
	mana_potion,
					
	//Depending on what Tomes are equipped, the various spells will appear in the "Spells" option
	//for battles. EG if you equip a fire tome and ice tome on one character, you'll see fire_one,
	//fire_all, ice_one, and ice_all in the "Spells" battle option for that unit in battles
	//Only give Tomes as rewards/buyable from shops, not the individual spells
	fire_one, 
	fire_all,
	ice_one,
	ice_all,
	heal_one,
	heal_all,
	last,
}

//This enum is designed so that the "can_equip" enumerators for the classes match up with the enums for the classes in e_stats
enum e_item_stats{
	name,
	fighter_can_equip,
	archer_can_equip,
	mage_can_equip,
	priest_can_equip,
	warrior_can_equip,
	knight_can_equip,
	ranger_can_equip,
	sniper_can_equip,
	wizard_can_equip,
	sorcerer_can_equip,
	healer_can_equip,
	monk_can_equip,
	cost,
	equip_where,	
									//all of the below stats are new										
	min_range,					//min and max range will be used for our scr_dispaly_active_nodes script
	max_range,					//and so they will dictate what tiles the item can be used on
	aoe_range,					//Once a tile is selected, what area around the tile will be affected? An
	mana_cost,					//AoE range of 0 will affect the selected tile only, 1 will affect adjacent tiles
	charges,						//-1 is infinite uses, a value of 0 will destroy the item
	stat_affected,				//Which stat is affected by this item? HP? Strength?
	value_affected,				//How much is the stat affected? 5? 10?
	must_target_an_actor,		//Do you have to choose a tile that contains an actor or not?
	item_type,					//is this item either melee/ranged or a spell or an item (like a healing potion) or misc (like a ring tha gives a constant buff)
	is_tome,						//does this "item" give other items to use as actions (eg a tome of fire gives fire_one and fire_all)
	which_tome,					//Does this "item" belong to a tome? If a tome is equipped and an "item" belongs to it, the "item" will appear in the "Spells" battle option
									//There's nothing stopping us saying that a sword is a tome, because we would just use the number that equals a sword, rather than one of
									//the tome numbers, and that means we can have a sword to use in melee as well as casting a spell, which is actually pretty cool!
}

//We want to match the item types up to the battle options so that when we select a battle option,
//we can fill a dynamic list with the possibilities for that particular unit
//EG if a unit has a sword and bow equipped, he'll see those two options under "Attack" as both
//Those items will have the "type" of "attack"
enum e_item_types{																						
	none = 0,
	attack = e_battle_menu.attack,
	spell = e_battle_menu.spell,
	item = e_battle_menu.item,
}

enum e_equip_where{
	hands,
	accessory,
	armour,
	item,
	nowhere,
}
//Let the item slots know what kind of items fit in that slot
global.gear_goes_where[e_stats.left_hand] = e_equip_where.hands;
global.gear_goes_where[e_stats.right_hand] = e_equip_where.hands;
global.gear_goes_where[e_stats.chest] = e_equip_where.armour;
global.gear_goes_where[e_stats.accessory] = e_equip_where.accessory;
global.gear_goes_where[e_stats.item_1] = e_equip_where.item;
global.gear_goes_where[e_stats.item_2] = e_equip_where.item;

//Create grid that holds item stats
global.items = load_csv("item_stats.csv");

//Create player inventory

//Create a list with 
global.inventory = ds_list_create();

/*
	The list will be a fixed size and have as many entries as there are items.
	The value in each entry will be the QUANTITY of each item that is in the inventory.
*/

//Set quantity for all items to 0 in the inventory
for (var i = 0; i < e_items.last; i ++){
	global.inventory[| i] = 0;	
}

//Add some items to the inventory
global.inventory[| e_items.leather_chest] = 2;
global.inventory[| e_items.sword] = 2;
global.inventory[| e_items.dagger] = 1;

#endregion

#region MAIN STATES														

enum e_main_states{
	title_screen,
	display_save_files,
	new_game,			
	load_game,
	game_ready,
	credits,		
}

global.main_state = e_main_states.title_screen;
global.current_save_file = 0;

scr_update_save_slot_text();

//CREATE MUSIC MANAGER
if (!instance_exists(obj_music_manager) )					
	instance_create_layer(0, 0, layer, obj_music_manager);

#endregion

#region CREDITS 

var count = 0;
a_credits[count] = "CREDITS"; count ++;
a_credits[count]  = ""; count ++;
a_credits[count]  = ""; count ++;
a_credits[count] = "[ -- CODING -- ]"; count ++;
a_credits[count]  = ""; count ++;
a_credits[count] = "GameMaker Rob"; count ++;
a_credits[count]  = ""; count ++;
a_credits[count]  = ""; count ++;
a_credits[count] = "[ -- ARTWORK - Tiles / Actors -- ]"; count ++;
a_credits[count]  = ""; count ++;
a_credits[count] = "Nerah"; count ++;
a_credits[count]  = ""; count ++;
a_credits[count]  = ""; count ++;
a_credits[count] = "[ -- ARTWORK - Overworld -- ]"; count ++;
a_credits[count]  = ""; count ++;
a_credits[count] = "Guard"; count ++;
a_credits[count]  = ""; count ++;
a_credits[count]  = ""; count ++;
a_credits[count]  = "[ -- MUSIC -- ]"; count ++;
a_credits[count]  = ""; count ++;
a_credits[count]  = "Grant Davis"; count ++;
a_credits[count]  = ""; count ++;
a_credits[count]  = ""; count ++;
a_credits[count]  = "[ -- BUGS -- ]"; count ++;
a_credits[count]  = ""; count ++;
a_credits[count]  = "Who knows!?"; count ++;
a_credits[count]  = ""; count ++;
a_credits[count]  = ""; count ++;
a_credits[count]  = "[ -- ARTWORK - The other stuff that isn't great -- ]"; count ++;
a_credits[count]  = ""; count ++;
a_credits[count]  = "Definitely not me!"; count ++;
a_credits[count]  = ""; count ++;
a_credits[count]  = ""; count ++;
a_credits[count]  = ""; count ++;
a_credits[count]  = ""; count ++;
a_credits[count]  = "A Special thank you to all of my patrons and"; count ++;
a_credits[count]  = "subscribers for supporting me and the channel"; count ++;
a_credits[count] = "and for voting for this series in the first place!"; count ++;

credit_x = display_get_gui_width() / 2;
credit_y = display_get_gui_height();

#endregion

//Vars used to create character sprites
sprites_created = false; //Sprites for characters will be created from a surface and the "all_units_sprite_sheet" sprite
                        //one step + draw event is needed to do this
						
sprite_surf = -1; //This will be the surface used to create sprites from

//Debugging - IMPORTANT - bugs with the garbage collector can make the game crash randomly pre-battle.
gc_enable(false);
