# BridgeGoer.gd
extends CharacterBody2D

signal action_complete
signal dialogue_trigger_reached
signal final_position_reached
signal timer_ran_out

@onready var sprite = $AnimatedSprite2D
@onready var timer = $Timer
@onready var timer_label = $Label
@onready var dialogue_bubble = $DialogueBubble

const WALK_SPEED = 70.0
const DECELERATION = 2.0

var wait_duration = 10.0
var target_position: Vector2

enum State { APPROACHING_TRIGGER, APPROACHING_BRIDGE, WAITING, DEPARTING }
var current_state = State.APPROACHING_TRIGGER

func _physics_process(delta):
	if current_state == State.WAITING:
		velocity = Vector2.ZERO
		return

	var direction = global_position.direction_to(target_position)
	var distance = global_position.distance_to(target_position)

	if current_state == State.APPROACHING_BRIDGE and distance < 15.0:
		velocity = velocity.move_toward(Vector2.ZERO, DECELERATION)
		if velocity == Vector2.ZERO:
			on_arrival_at_target()
	elif distance < 5.0:
		on_arrival_at_target()
	else:
		velocity = direction * WALK_SPEED

	move_and_slide()

func initialize(start_pos: Vector2, dialogue_pos: Vector2, bridge_pos: Vector2):
	position = start_pos
	target_position = dialogue_pos
	set_silhouette(true)
	sprite.play("walk")
	sprite.flip_h = false
	
	dialogue_trigger_reached.connect(func(): 
		current_state = State.APPROACHING_BRIDGE
		target_position = bridge_pos
	)

func on_arrival_at_target():
	if current_state == State.APPROACHING_TRIGGER:
		position = target_position
		dialogue_trigger_reached.emit()
	elif current_state == State.APPROACHING_BRIDGE:
		if velocity != Vector2.ZERO: return
		position = target_position
		current_state = State.WAITING
		sprite.play("idle")
		get_tree().create_timer(0.5).timeout.connect(func(): final_position_reached.emit())
	elif current_state == State.DEPARTING:
		action_complete.emit()
		queue_free()

func depart(is_safe_exit: bool):
	if current_state == State.DEPARTING: return
	timer.stop()
	
	current_state = State.DEPARTING
	sprite.play("walk")

	if is_safe_exit:
		target_position = position + Vector2(400, 0)
		sprite.flip_h = false
	else:
		target_position = position - Vector2(400, 0)
		sprite.flip_h = true
	
	timer_label.hide()
	dialogue_bubble.hide()

func on_timer_timeout():
	depart(false)

func reveal_and_start_timer():
	dialogue_bubble.hide()
	set_silhouette(false)
	timer_label.show()
	timer.start()
	
	var control_tween = create_tween()
	return control_tween

func show_dialogue(text: String):
	dialogue_bubble.text = text
	dialogue_bubble.show()
	# Return the timer so Main knows when it's done
	return get_tree().create_timer(3.0)

func set_silhouette(is_silhouetted: bool):
	if is_silhouetted:
		sprite.modulate = Color.BLACK
	else:
		var tween = create_tween()
		tween.tween_property(sprite, "modulate", Color.WHITE, 0.3).from_current()

func _ready():
	timer.wait_time = wait_duration
	timer.one_shot = true
	timer.timeout.connect(on_timer_timeout)
	timer_label.hide()
	dialogue_bubble.hide()

func _process(delta):
	if !timer.is_stopped():
		timer_label.text = "%.1f" % timer.time_left
