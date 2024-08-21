/// @description CREATE ACTOR SPRITES FROM SPRITE SHEET - RUNS ON VERY FIRST DRAW OF THE GAME
if (sprites_created == false){ // We only want this code to run once, so we use a boolean and set it to true at the end
	
	#region CREATE SPRITES FOR EVERY PLAYER CHARACTER AND EVERY STATE FROM 1 SPRITE SHEET
	
	#region CREATE/SET a surface and draw the sprite sheet to it
	
	if (!surface_exists(sprite_surf)) sprite_surf = surface_create(sprite_get_width(all_units_sprite_sheet_player), sprite_get_height(all_units_sprite_sheet_player) );
	
	surface_set_target(sprite_surf);
	
	draw_sprite(all_units_sprite_sheet_player, 0, 0, 0);
	
	#endregion
	
	global.char_sprite_grids = ds_list_create();	
	
	var images_per_anim = 4; //How many images per animation? If this is dynamic, some extra setting up is required
	var actions_start = e_actor_sprites.idle; //Which horizontal cell in the spritesheet do we want to start copying from? We want to miss out the black edges etc													
	var actions_end = e_actor_sprites.last; //Which horizontal cell should be the last to copy from						
	var facing = 0;																				
	var total_facings = 4;	
	var image_width = 32; //Again, extra setup is needed if the width of the animations changes based on character/class
	var image_height = 32; //Same as above
	
	//Facing and total facings deal with the vertical cells. Every character has 4 rows/vertical cells, and then the next four are a different character/class

	//For as many characters/classes that there are, 
	for (var character = 0; character < e_characters.last; character ++){	
		
		//create a grid that will hold 4 sprites for each of the 4 actions for each character
		var char_grid = ds_grid_create(e_actor_sprites.last, total_facings);

		//For as many facings as there are (4)
		for (var yy = facing; yy < total_facings; yy ++){
			
			//xx and yy will be used to store sprites in the relevant cell for the character's grid
			for (var xx = actions_start; xx < actions_end; xx ++){
				//Create Initial Sprite for the different state animations - has 1 frame
				var x_point = (xx * images_per_anim) * image_width;
				var y_point = (yy * image_height) + (character * total_facings * image_height);
				
				//We have to create an initial sprite to be able to add images to it
				char_grid[# xx, yy] = sprite_create_from_surface(sprite_surf, x_point, y_point, image_width, image_height, false, false, 16, 25);

				//Add additional frames to this sprite
				for (var index = 1; index < 4; index ++){
					
					sprite_add_from_surface(char_grid[# xx, yy], sprite_surf, x_point + (index * image_width), y_point, image_width, image_height, false, false);
				}
			}
		}
		
		global.char_sprite_grids[| character] = char_grid;	
		
	}
	//We're done with the surface for now
	surface_reset_target();
	surface_free(sprite_surf);
	
	#endregion

	#region CREATE SPRITES FOR EVERY ENEMY CHARACTER AND EVERY STATE FROM 1 SPRITE SHEET
	
	//This is exactly the same as above, but uses the enemy sprite sheet and a different global list
	
	#region CREATE/SET SURFACE
	
	if (!surface_exists(sprite_surf)) sprite_surf = surface_create(sprite_get_width(all_units_sprite_sheet_enemy), sprite_get_height(all_units_sprite_sheet_enemy) );
	
	surface_set_target(sprite_surf);
	
	#endregion
	
	draw_sprite(all_units_sprite_sheet_enemy, 0, 0, 0);
	
	global.char_sprite_grids_enemy = ds_list_create();	
	
	var images_per_anim = 4;
	var actions_start = e_actor_sprites.idle;													
	var actions_end = (e_actor_sprites.last);								
	var facing = 0;																				
	var total_facings = 4;	

	for (var character = 0; character < e_characters.last; character ++){	
		
		//The grid will hold 4 sprites for each of the 4 actions for each character
		var char_grid = ds_grid_create(e_actor_sprites.last, total_facings);

		for (var yy = facing; yy < total_facings; yy ++){
			
			//xx and yy will bs used to store sprites in the relevant cell for the character's grid

			for (var xx = actions_start; xx < actions_end; xx ++){
				//Create Initial Sprite for the different state animations - has 1 frame
				var x_point = (xx * images_per_anim) * 32;
				var y_point = (yy * 32) + (character * 4 * 32);
				
				char_grid[# xx, yy] = sprite_create_from_surface(sprite_surf, x_point, y_point, 32, 32, false, false, 16, 25);

				//Add additional frames to this sprite
				for (var index = 1; index < 4; index ++){
					
					sprite_add_from_surface(char_grid[# xx, yy], sprite_surf, x_point + (index * 32), y_point, 32, 32, false, false);
					
				}
			}
		}
		
		global.char_sprite_grids_enemy[| character] = char_grid;	
		
	}
	
	surface_reset_target();
	
	sprites_created = true;
	
	show_debug_message("Sprites created");
	
	#endregion
	
}
