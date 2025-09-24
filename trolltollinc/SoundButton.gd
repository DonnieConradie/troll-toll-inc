# SoundButton.gd
extends Button

func _ready():
	mouse_entered.connect(on_mouse_entered)
	pressed.connect(on_pressed)

func on_mouse_entered():
	SoundManager.play("ui_hover")

func on_pressed():
	SoundManager.play("ui_click")
