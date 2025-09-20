# Troll.gd
extends AnimatedSprite2D

signal is_dropping(duration: float)

var current_target = null

func _ready():
	play("idle")

func set_target(bridge_goer):
	current_target = bridge_goer
	if current_target:
		current_target.tree_exiting.connect(_on_target_exiting, CONNECT_ONE_SHOT)

func get_target():
	return current_target

func _on_target_exiting():
	current_target = null
	if animation == "peek" or animation == "jump":
		start_drop_sequence()

func action_peek():
	play("jump")

func action_eat():
	if current_target:
		play("eat")
		current_target.queue_free()

func action_pass():
	if current_target:
		if animation == "peek":
			start_drop_sequence()

func start_drop_sequence():
	if animation == "drop": return # Avoid starting it if already dropping
	
	play("drop")
	var speed = sprite_frames.get_animation_speed("drop")
	var frame_count = sprite_frames.get_frame_count("drop")
	var duration = frame_count / speed
	is_dropping.emit(duration)

func _on_animation_finished():
	if animation == "jump":
		play("peek")
	elif animation == "drop":
		play("idle")
	elif animation == "eat":
		start_drop_sequence()
