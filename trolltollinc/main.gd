# Main.gd
extends Node2D

@onready var top_world_material = $TopWorld.material
@onready var spawn_point_left: Marker2D = $TopWorld/SpawnPointLeft
@onready var bridge_point: Marker2D = $TopWorld/BridgePoint
@onready var exit_point_right: Marker2D = $TopWorld/ExitPointRight
@onready var troll = $Troll
@onready var gold_label: Label = $CanvasLayer/MarginContainer/HBoxContainer/VBoxContainer/GoldLabel
@onready var hunger_bar: TextureProgressBar = $CanvasLayer/MarginContainer/HBoxContainer/HBoxContainer2/HungerBar
@onready var scare_bar: TextureProgressBar = $CanvasLayer/MarginContainer/HBoxContainer/HBoxContainer2/ScareBar
@onready var inspect_button = $CanvasLayer/InspectButton
@onready var eat_button = $CanvasLayer/EatButton
@onready var pass_button = $CanvasLayer/PassButton
@onready var censored_label = $CanvasLayer/CensoredLabel
@onready var dialogue_trigger_point = $DialogueTriggerPoint
@onready var troll_dialogue_bubble = $TrollDialogueBubble
@onready var fax_machine = $FaxMachine
@onready var grab_paper_button = $CanvasLayer/GrabPaperButton

const DECREE_PANEL_SCENE = preload("res://decree_panel.tscn")


var day_goat_index = 0
const GoatData = preload("res://GoatData.gd")
var goat_data_script = GoatData.new()

const BRIDGE_GOER_SCENE = preload("res://bridge_goer.tscn")

var hunger = 100
var gold = 0
var scare_factor = 50
var current_day = 1
var day_1_goat_index = 0

enum GameState { NONE, DIALOGUE, WAITING_FOR_INSPECT, WAITING_FOR_DECISION }
var current_state = GameState.NONE

var troll_questions = [ "Who goes there?!", "What's the password?", "State your business!", "You dare cross my bridge?", "Halt! Who goes trip-trapping over my bridge?" ]
var goat_answers = [ "Just a goat, sir!", "Ag, please man, just let me pass.", "Grumblegut", "I'm just a simple farmer... goat.", "My bru, I'm just trying to get to the other side." ]

func _ready():
	inspect_button.pressed.connect(on_inspect_button_pressed)
	eat_button.pressed.connect(on_eat_button_pressed)
	pass_button.pressed.connect(on_pass_button_pressed)
	troll.is_dropping.connect(on_troll_is_dropping)
	
	censored_label.hide()
	troll_dialogue_bubble.hide()
	set_button_visibility(false, false, false)
	update_ui()
	top_world_material.set_shader_parameter("silhouette_strength", 1.0)
	get_tree().create_timer(1.0).timeout.connect(spawn_character)

func on_troll_is_dropping(duration: float):
	var tween = create_tween()
	tween.tween_property(top_world_material, "shader_parameter/silhouette_strength", 1.0, duration)

func set_button_visibility(inspect: bool, eat: bool, pass_btn: bool):
	inspect_button.visible = inspect
	eat_button.visible = eat
	pass_button.visible = pass_btn

func update_ui():
	hunger_bar.value = hunger
	scare_bar.value = scare_factor
	gold_label.text = "%s" % gold


func spawn_character():
	var current_day_goats = GoatData.DAYS_DATA[current_day]
	
	if day_goat_index >= current_day_goats.size():
		print("End of Day ", current_day)
		start_end_of_day_sequence()
		return

	var goat_to_spawn_data = current_day_goats[day_goat_index]
	day_goat_index += 1

	var new_goer = BRIDGE_GOER_SCENE.instantiate()
	add_child(new_goer)
	
	new_goer.initialize(
		goat_to_spawn_data,
		spawn_point_left.position, 
		dialogue_trigger_point.position, 
		bridge_point.position
	)
	
	new_goer.action_complete.connect(on_goat_action_complete)
	new_goer.dialogue_trigger_reached.connect(on_goat_reaches_trigger)
	new_goer.final_position_reached.connect(on_goat_reaches_bridge)
	new_goer.timer_ran_out.connect(on_goat_timer_ran_out)
	troll.set_target(new_goer)

	current_state = GameState.DIALOGUE
	set_button_visibility(false, false, false)


func on_goat_timer_ran_out():
	current_state = GameState.NONE
	set_button_visibility(false, false, false)
	troll.action_pass()

func on_goat_reaches_trigger():
	var troll_question = troll_questions.pick_random()
	troll_dialogue_bubble.text = troll_question
	troll_dialogue_bubble.show()
	get_tree().create_timer(3.0).timeout.connect(func(): troll_dialogue_bubble.hide())

func on_goat_reaches_bridge():
	var goat_answer = goat_answers.pick_random()
	var target = troll.get_target()
	if target:
		var dialogue_timer = target.show_dialogue(goat_answer)
		await dialogue_timer.timeout
		
	current_state = GameState.WAITING_FOR_INSPECT
	set_button_visibility(true, false, true)

func on_goat_action_complete():
	current_state = GameState.NONE
	set_button_visibility(false, false, false)
	get_tree().create_timer(4.0).timeout.connect(spawn_character)


func start_end_of_day_sequence():
	current_state = GameState.NONE
	set_button_visibility(false, false, false)
	
	# Play fax sound here
	fax_machine.play("printing")
	fax_machine.animation_finished.connect(on_fax_printed, CONNECT_ONE_SHOT)

func on_fax_printed():
	fax_machine.play("idle")
	grab_paper_button.show()
	grab_paper_button.pressed.connect(show_next_decree, CONNECT_ONE_SHOT)

func show_next_decree():
	grab_paper_button.hide()
	current_day += 1
	
	if not GoatData.DAYS_DATA.has(current_day):
		print("YOU WON THE GAME!")
		# Add end-of-game logic here
		return

	var decree_panel = DECREE_PANEL_SCENE.instantiate()
	add_child(decree_panel)
	
	var next_decree_text = GoatData.DECREE_TEXTS[current_day]
	decree_panel.show_decree(next_decree_text)
	decree_panel.mandate_accepted.connect(start_new_day)

func start_new_day():
	day_goat_index = 0
	spawn_character()


func on_inspect_button_pressed():
	if current_state == GameState.WAITING_FOR_INSPECT:
		current_state = GameState.WAITING_FOR_DECISION
		
		troll.action_peek()
		var target = troll.get_target()
		if target:
			var tween = target.reveal_and_start_timer()
			tween.tween_property(top_world_material, "shader_parameter/silhouette_strength", 0.0, 0.3)
		
		set_button_visibility(false, true, true)

func on_eat_button_pressed():
	if current_state == GameState.WAITING_FOR_DECISION:
		hunger = clamp(hunger + 20, 0, 100)
		scare_factor = clamp(scare_factor + 15, 0, 100)
		update_ui()
		
		censored_label.show()
		get_tree().create_timer(0.5).timeout.connect(func(): censored_label.hide())
		
		troll.action_eat()
		on_goat_action_complete()

func on_pass_button_pressed():
	var target = troll.get_target()
	if !target: return

	if current_state == GameState.WAITING_FOR_INSPECT or current_state == GameState.WAITING_FOR_DECISION:
		gold += 10
		scare_factor = clamp(scare_factor - 10, 0, 100)
		update_ui()
		
		var is_safe = true
		target.depart(is_safe)
		troll.action_pass()
		
		current_state = GameState.NONE
		set_button_visibility(false, false, false)
