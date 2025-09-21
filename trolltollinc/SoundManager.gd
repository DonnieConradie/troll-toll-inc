# SoundManager.gd
extends Node


var sound_players = {}

func _ready():
	add_sound("ui_click", "res://assets/sound/ui_click.MP3")
	add_sound("crunch", "res://assets/sound/crunch.mp3")
	add_sound("cha_ching", "res://assets/sound/cha_ching.mp3")
	add_sound("paper_grab", "res://assets/sound/paper_grab.mp3")
	add_sound("fax_noises", "res://assets/sound/fax_noises.mp3")
	add_sound("printing", "res://assets/sound/printing.mp3")

func add_sound(sound_name, path):
	var p = AudioStreamPlayer.new()
	p.stream = load(path)
	sound_players[sound_name] = p
	add_child(p)

func play(sound_name):
	if sound_players.has(sound_name):
		sound_players[sound_name].play()
