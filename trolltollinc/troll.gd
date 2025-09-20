# Troll.gd
extends AnimatedSprite2D

var current_target = null

func _ready():
	play("idle")

func set_target(bridge_goer):
	current_target = bridge_goer

func get_target():
	return current_target

func action_peek():
	play("jump")

func action_eat():
	if current_target:
		play("eat")
		current_target.queue_free()
		current_target = null
		play("drop")

func action_pass():
	if current_target:
		play("drop")
		current_target.queue_free()
		current_target = null

func _on_animation_finished():
	if animation == "jump":
		play("peek")
	if animation == "drop":
		play("idle")
