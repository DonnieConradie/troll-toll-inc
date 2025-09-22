extends Control


@onready var start_button = $StartButton

func _ready():
	start_button.pressed.connect(on_start_pressed)

func on_start_pressed():
	# Our intro scene is the true start of the game.
	get_tree().change_scene_to_file("res://Intro.tscn")
