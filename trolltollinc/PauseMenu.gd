# PauseMenu.gd
extends Control


@onready var continue_button = $ContinueButton
@onready var quit_button = $ExitButton
@onready var volume_slider: HSlider = $MusicVolumeSlider


func _ready():
	continue_button.pressed.connect(close_menu)
	quit_button.pressed.connect(on_quit_pressed)
	volume_slider.value_changed.connect(_on_volume_slider_changed)
	
	volume_slider.value = SoundManager.music_volume_db

func _unhandled_input(event):
	if visible and Input.is_action_just_pressed("ui_cancel"):
		close_menu()
		get_tree().get_root().set_input_as_handled()

func close_menu():
	get_tree().paused = false
	hide()

func on_quit_pressed():
	SoundManager.transition_to_scene("res://main_menu.tscn")

func _on_volume_slider_changed(value: float):
	SoundManager.set_music_volume(value)
