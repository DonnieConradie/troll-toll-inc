# EndScreen.gd
extends Control

@onready var retry_button = $RetryButton
@onready var exit_button = $ExitButton
@onready var click: AudioStreamPlayer = $Click
@onready var hover: AudioStreamPlayer = $Hover

func _ready():
	retry_button.pressed.connect(on_retry_pressed)
	exit_button.pressed.connect(on_exit_pressed)

func on_retry_pressed():
	get_tree().change_scene_to_file("res://main_menu.tscn")

func on_exit_pressed():
	get_tree().quit()

func _on_button_pressed() -> void:
	click.play()

func _on_mouse_entered() -> void:
	hover.play()
