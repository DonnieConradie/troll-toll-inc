# BridgeGoer.gd
extends CharacterBody2D

signal action_complete
signal dialogue_trigger_reached
signal final_position_reached
signal timer_ran_out

@onready var body_sprite = $BodySprite
@onready var horns_sprite = $BodySprite/Horns
@onready var head_accessory_sprite = $BodySprite/HeadAccessory
@onready var body_accessory_sprite = $BodySprite/BodyAccessory
@onready var hand_accessory_sprite = $BodySprite/HandAccessory
@onready var hooves_sprite = $BodySprite/Hooves
@onready var animation_player = $AnimationPlayer
@onready var timer = $Timer
@onready var timer_label = $Label
@onready var dialogue_bubble = $DialogueBubble

const WALK_SPEED = 70.0
const DECELERATION = 2.0

var wait_duration = 10.0
var target_position: Vector2

enum State { APPROACHING_TRIGGER, APPROACHING_BRIDGE, WAITING, DEPARTING }
var current_state = State.APPROACHING_TRIGGER

var goat_data: Dictionary

# --- Initialization ---

func initialize(data: Dictionary, start_pos: Vector2, dialogue_pos: Vector2, bridge_pos: Vector2):
	goat_data = data
	apply_goat_data()
	
	position = start_pos
	target_position = dialogue_pos
	set_silhouette(true)
	animation_player.play("walk")
	body_sprite.flip_h = false
	
	dialogue_trigger_reached.connect(func(): 
		current_state = State.APPROACHING_BRIDGE
		target_position = bridge_pos
	)

func apply_goat_data():
	var size = goat_data["size"]
	scale = Vector2(abs(size), abs(size))
	
	var components = goat_data["components"]
	load_accessory(horns_sprite, components["horns"])
	load_accessory(head_accessory_sprite, components["head"])
	load_accessory(body_accessory_sprite, components["body"])
	load_accessory(hand_accessory_sprite, components["hand"])
	
	var hooves_type = components["feet"]
	if hooves_type != "none":
		# --- THIS IS THE CORRECTED LINE ---
		# We add the "hooves_" prefix to match your resource names.
		hooves_sprite.animation = "hooves_" + hooves_type + "_idle"
		hooves_sprite.visible = true
	else:
		hooves_sprite.visible = false

func load_accessory(sprite: Sprite2D, accessory_name: String):
	if accessory_name != "none":
		sprite.texture = load("res://assets/visual/accessories/" + accessory_name + ".png")
		sprite.visible = true
	else:
		sprite.visible = false


# --- Movement & State Machine ---

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

func on_arrival_at_target():
	if current_state == State.APPROACHING_TRIGGER:
		position = target_position
		dialogue_trigger_reached.emit()
	elif current_state == State.APPROACHING_BRIDGE:
		if velocity != Vector2.ZERO: return
		position = target_position
		current_state = State.WAITING
		animation_player.play("idle")
		get_tree().create_timer(0.5).timeout.connect(func(): final_position_reached.emit())
	elif current_state == State.DEPARTING:
		action_complete.emit()
		queue_free()

func depart(is_safe_exit: bool):
	if current_state == State.DEPARTING: return
	timer.stop()
	
	current_state = State.DEPARTING
	animation_player.play("walk")

	if is_safe_exit:
		target_position = position + Vector2(400, 0)
		scale.x = goat_data["size"] # Reset to normal scale
	else:
		target_position = position - Vector2(400, 0)
		scale.x = -goat_data["size"] # Flip by making scale negative
	
	timer_label.hide()
	dialogue_bubble.hide()


# --- UI & Effects ---

func on_timer_timeout():
	timer_ran_out.emit()
	depart(false)

func reveal_and_start_timer():
	dialogue_bubble.hide()
	set_silhouette(false)
	timer_label.show()
	timer.start()
	return create_tween()

func show_dialogue(text: String):
	dialogue_bubble.text = text
	dialogue_bubble.show()
	return get_tree().create_timer(3.0)

func set_silhouette(is_silhouetted: bool):
	if is_silhouetted:
		modulate = Color.BLACK
	else:
		var tween = create_tween()
		tween.tween_property(self, "modulate", Color.WHITE, 0.3).from_current()

func _ready():
	timer.wait_time = wait_duration
	timer.one_shot = true
	timer.timeout.connect(on_timer_timeout)
	timer_label.hide()
	dialogue_bubble.hide()

func _process(delta):
	if !timer.is_stopped():
		timer_label.text = "%.1f" % timer.time_left
