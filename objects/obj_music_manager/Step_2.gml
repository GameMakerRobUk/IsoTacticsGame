#region UPDATE STATE

if (global.main_state == e_main_states.title_screen) state = e_music.title_drama;
if (global.main_state == e_main_states.game_ready) state = e_music.overworld;
if (instance_exists(obj_player) && obj_player.state == e_player_states.talking)
	state = e_music.title_drama;
if (instance_exists(obj_scene) && obj_scene.state == e_misc_states.in_battle)
	state = e_music.battle;
	
#endregion

#region CHANGE MUSIC

var wanted_music = music[state];

if (current_music != wanted_music){
	if (current_music != -1) audio_stop_sound(current_music);
	if (wanted_music != -1) audio_play_sound(wanted_music, 0, true);
	current_music = wanted_music;
}

#endregion