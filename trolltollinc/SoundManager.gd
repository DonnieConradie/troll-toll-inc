# SoundManager.gd
extends Node

var sound_players = {}
var is_initialized = false
var game_music_player: AudioStreamPlayer
var music_volume_db: float = -20.0

func initialize():
	if is_initialized: return
	is_initialized = true
	add_sound("ui_click", "res://assets/sound/ui_click.MP3")
	add_sound("crunch", "res://assets/sound/snd_error_01.mp3")
	add_sound("cha_ching", "res://assets/sound/cha_ching.mp3")
	add_sound("paper_grab", "res://assets/sound/paper_grab.MP3")
	add_sound("eat_sound", "res://assets/sound/crunch.mp3")
	add_sound("fax_noises", "res://assets/sound/fax_noises.mp3")
	add_sound("printing", "res://assets/sound/printing.mp3")
	add_sound("drumroll", "res://assets/sound/drumroll_01.MP3")
	add_sound("ui_hover", "res://assets/sound/hover.wav")
	add_sound("ui_click", "res://assets/sound/click.wav")
	
	game_music_player = AudioStreamPlayer.new()
	game_music_player.stream = load("res://assets/sound/music/mining-by-moonlight-kevin-macleod-main-version-03-15-12960.mp3")
	game_music_player.name = "GameMusicPlayer"
	game_music_player.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(game_music_player)

func add_sound(sound_name, path):
	var p = AudioStreamPlayer.new()
	p.stream = load(path)
	sound_players[sound_name] = p
	add_child(p)

func play(sound_name):
	if !is_initialized:
		print("ERROR: SoundManager not initialized!")
		return
		
	if sound_players.has(sound_name):
		sound_players[sound_name].play()

func transition_to_scene(scene_path: String):
	get_tree().paused = false
	get_tree().change_scene_to_file(scene_path)

func set_music_volume(db_value: float):
	music_volume_db = db_value
	if game_music_player:
		game_music_player.volume_db = music_volume_db

func play_game_music():
	if !game_music_player.playing:
		game_music_player.volume_db = music_volume_db
		game_music_player.play()

func stop_all_music():
	if game_music_player.playing:
		game_music_player.stop()
