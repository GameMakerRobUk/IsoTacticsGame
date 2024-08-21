#region MUSIC

enum e_music{
	title_drama,
	overworld,
	battle,
	off,
}

music[e_music.title_drama] = mus_title_and_drama;
music[e_music.overworld] = mus_overworld;
music[e_music.battle] = mus_battle;
music[e_music.off] = -1;

state = e_music.off;

//Stores the current sound resource that is playing
current_music = music[state];

#endregion
//Dont play music

audio_stop_all();
instance_destroy();