# WinScreen.gd
extends Control

@onready var menu_button = $MenuButton
@onready var click: AudioStreamPlayer = $Click
@onready var hover: AudioStreamPlayer = $Hover

func _ready():
	menu_button.pressed.connect(on_menu_pressed)

func on_menu_pressed():
	get_tree().change_scene_to_file("res://main_menu.tscn")

func on_exit_pressed():
	get_tree().quit()

func _on_button_pressed() -> void:
	click.play()

func _on_mouse_entered() -> void:
	hover.play()
