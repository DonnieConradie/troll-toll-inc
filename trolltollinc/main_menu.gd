# MainMenu.gd
extends Control

@export var intro_scene: PackedScene

@onready var start_button = $StartButton
@onready var how_to_play_button = $HowToPlayButton
@onready var fullscreen_button = $FullscreenButton
@onready var exit_button = $ExitButton
@onready var hover: AudioStreamPlayer = $Hover
@onready var click: AudioStreamPlayer = $Click

const DECREE_PANEL_SCENE = preload("res://decree_panel.tscn")
const HOW_TO_PLAY_TEXT = """
HOW TO PLAY\n
GOAL: Survive as many days as possible.
1. A goat appears. Read its dialogue.
2. Based on the daily mandate, you must either PASS the goat immediately or INSPECT it for more clues.
3. If you inspect, you must EAT or PASS the goat before the timer runs out.
Make 3 mistakes, and you're fired.
"""

func _ready():
	SoundManager.initialize()
	SoundManager.stop_all_music()
	start_button.pressed.connect(on_start_pressed)
	how_to_play_button.pressed.connect(on_how_to_play_pressed)
	fullscreen_button.pressed.connect(on_fullscreen_pressed)
	exit_button.pressed.connect(on_exit_pressed)

func on_start_pressed():
	get_tree().change_scene_to_packed(intro_scene)

func on_how_to_play_pressed():
	var how_to_play_panel = DECREE_PANEL_SCENE.instantiate()
	add_child(how_to_play_panel)
	how_to_play_panel.show_decree(HOW_TO_PLAY_TEXT)
	how_to_play_panel.set_accept_button_text("Got It")

func on_fullscreen_pressed():
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func on_exit_pressed():
	get_tree().quit()

func _on_mouse_entered() -> void:
	hover.play()

func _on_button_pressed() -> void:
	click.play()
