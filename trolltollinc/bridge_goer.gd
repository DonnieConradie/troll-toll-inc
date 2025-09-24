class_name BridgeGoer
extends CharacterBody2D

signal action_complete
signal dialogue_trigger_reached
signal final_position_reached
signal timer_ran_out
signal wants_to_speak(text)

@onready var body_sprite = $BodySprite
@onready var horns_sprite = $BodySprite/Horns
@onready var head_accessory_sprite = $BodySprite/HeadAccessory
@onready var head_accessory_2_sprite = $BodySprite/HeadAccessory2
@onready var body_accessory_sprite = $BodySprite/BodyAccessory
@onready var hand_accessory_sprite = $BodySprite/HandAccessory
@onready var hooves_sprite = $BodySprite/Hooves
@onready var animation_player = $AnimationPlayer
@onready var timer = $Timer
@onready var timer_label = $Label
@onready var footstep_player = $FootstepPlayer

const WALK_SPEED = 70.0
const DECELERATION = 3.0
const DANGER_COLOR = Color("#bb474f")

var wait_duration = 6.0
var initial_label_scale: Vector2
var target_position: Vector2

enum State { APPROACHING_TRIGGER, APPROACHING_BRIDGE, WAITING, DEPARTING }
var current_state = State.APPROACHING_TRIGGER
var goat_data: Dictionary
var footstep_sounds = [
	preload("res://assets/sound/footsteps_01.MP3"),
	preload("res://assets/sound/footsteps_02.MP3"),
	preload("res://assets/sound/footsteps_03.MP3"),
	preload("res://assets/sound/footsteps_04.MP3"),
	preload("res://assets/sound/footsteps_05.MP3"),
	preload("res://assets/sound/footsteps_06.MP3")
]

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

func initialize(data: Dictionary, start_pos: Vector2, dialogue_pos: Vector2, bridge_pos: Vector2):
	goat_data = data
	apply_goat_data()
	
	position = start_pos
	target_position = dialogue_pos
	set_silhouette(true)
	set_animation_state("walk")
	
	dialogue_trigger_reached.connect(func(): 
		current_state = State.APPROACHING_BRIDGE
		target_position = bridge_pos
	)

func apply_goat_data():
	var body_type = goat_data.get("body_type", "normal")
	var components = goat_data["components"]
	load_accessory(horns_sprite, components["horns"])
	load_accessory(head_accessory_sprite, components["head"])
	load_accessory(head_accessory_2_sprite, components["head2"])
	load_accessory(body_accessory_sprite, components["body"])
	load_accessory(hand_accessory_sprite, components["hand"])
	
func load_accessory(sprite: Sprite2D, accessory_name: String):
	if accessory_name != "none":
		sprite.texture = load("res://assets/visual/accessories/" + accessory_name + ".png")
		sprite.visible = true
	else:
		sprite.visible = false

func set_animation_state(state_name: String):
	var body_type = goat_data.get("body_type", "normal")

	# --- THIS IS THE FIX ---
	if body_type == "normal":
		body_sprite.animation = state_name # Results in "walk" or "idle"
	else:
		body_sprite.animation = body_type + "_" + state_name # Results in "skinny_walk" or "skinny_idle"
	
	var hooves_type = goat_data["components"]["feet"]
	if hooves_type != "none":
		hooves_sprite.animation = "hooves_" + hooves_type + "_" + state_name
		hooves_sprite.visible = true
	else:
		hooves_sprite.visible = false
	
	animation_player.play(state_name)

func play_random_footstep():
	var random_sound = footstep_sounds.pick_random()
	footstep_player.stream = random_sound
	footstep_player.play()

func on_arrival_at_target():
	if current_state == State.APPROACHING_TRIGGER:
		position = target_position
		dialogue_trigger_reached.emit()
	elif current_state == State.APPROACHING_BRIDGE:
		if velocity != Vector2.ZERO: return
		position = target_position
		current_state = State.WAITING
		set_animation_state("idle")
		get_tree().create_timer(0.5).timeout.connect(func(): final_position_reached.emit())
	elif current_state == State.DEPARTING:
		action_complete.emit()
		queue_free()

func depart(is_safe_exit: bool):
	if current_state == State.DEPARTING: return
	timer.stop()
	
	current_state = State.DEPARTING
	set_animation_state("walk")

	if is_safe_exit:
		target_position = position + Vector2(400, 0)
		set_flipped(false)
	else:
		target_position = position - Vector2(400, 0)
		set_flipped(true)
	
	timer_label.hide()

func set_flipped(is_flipped: bool):
	body_sprite.flip_h = is_flipped
	for child in body_sprite.get_children():
		if child is Sprite2D or child is AnimatedSprite2D:
			child.flip_h = is_flipped

func on_timer_timeout():
	timer_ran_out.emit()
	depart(false)

func reveal_and_start_timer():
	# dialogue_bubble.hide() is no longer needed here
	set_silhouette(false)
	timer_label.show()
	timer.start()
	return create_tween()

func show_dialogue(text: String):
	wants_to_speak.emit(text)
	return get_tree().create_timer(3.0)

func stop_timer():
	timer.stop()
	timer_label.hide()

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
	initial_label_scale = timer_label.scale


func _process(delta):
	if !timer.is_stopped():
		timer_label.text = "%.1f" % timer.time_left
		
		# Check if we are in the "danger zone"
		if timer.time_left < 3.0:
			timer_label.modulate = DANGER_COLOR
			timer_label.scale = initial_label_scale * 1.5 # Make it 50% larger
		else:
			# Reset to normal state if not in danger zone
			timer_label.modulate = Color.WHITE
			timer_label.scale = initial_label_scale
	else:
		# Ensure it's reset when the timer is not running at all
		timer_label.modulate = Color.WHITE
		timer_label.scale = initial_label_scale
