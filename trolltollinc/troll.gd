# Troll.gd
extends AnimatedSprite2D

signal is_dropping(duration: float)
@onready var sound_player = $SoundPlayer

var current_target = null
var land_sound = preload("res://assets/sound/Landing_02.MP3")

const LAND_IMPACT_FRAME = 3

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
	if animation == "drop": return
	
	play("drop")
	var drop_duration = 0.5 
	is_dropping.emit(drop_duration)
	
func play_land_sound():
	sound_player.stream = land_sound
	sound_player.play()

func _on_animation_finished():
	if animation == "jump":
		play("peek")
	elif animation == "drop":
		play("idle")
	elif animation == "eat":
		start_drop_sequence()

func _on_frame_changed():
	if animation == "drop":
		if frame == LAND_IMPACT_FRAME:
			sound_player.stream = land_sound
			sound_player.play()
