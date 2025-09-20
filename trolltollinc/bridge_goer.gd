# BridgeGoer.gd
extends CharacterBody2D

signal time_ran_out

@onready var sprite = $AnimatedSprite2D
@onready var timer = $Timer
@onready var timer_label = $Label

var wait_duration = 10.0

func _ready():
	sprite.play("idle")

	timer.wait_time = wait_duration
	timer.one_shot = true
	timer.timeout.connect(on_timer_timeout)
	timer.start()
	
	timer_label.text = str(wait_duration)

func _process(delta):
	timer_label.text = "%.1f" % timer.time_left

func on_timer_timeout():
	time_ran_out.emit()
	queue_free()

func set_silhouette(is_silhouetted: bool):
	if is_silhouetted:
		sprite.modulate = Color.BLACK
	else:
		var tween = create_tween()
		tween.tween_property(sprite, "modulate", Color.WHITE, 0.3).from_current()
