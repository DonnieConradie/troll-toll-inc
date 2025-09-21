# Intro.gd
extends Node2D

@onready var audio_player = $AudioStreamPlayer
const DECREE_PANEL_SCENE = preload("res://decree_panel.tscn")
const GoatData = preload("res://GoatData.gd")

func _ready():
	await get_tree().create_timer(1.0).timeout
	audio_player.play()

func show_first_decree():
	var decree_panel = DECREE_PANEL_SCENE.instantiate()
	add_child(decree_panel)
	var decree_text = GoatData.DECREE_TEXTS[1]
	decree_panel.show_decree(decree_text)
	decree_panel.mandate_accepted.connect(go_to_main_game)

func go_to_main_game():
	get_tree().change_scene_to_file("res://main.tscn")

func _on_audio_stream_player_finished() -> void:
	show_first_decree()
