# Main.gd
extends Node2D

@onready var top_world_material = $TopWorld.material
@onready var spawn_point_left: Marker2D = $TopWorld/SpawnPointLeft
@onready var bridge_point: Marker2D = $TopWorld/BridgePoint
@onready var exit_point_right: Marker2D = $TopWorld/ExitPointRight
@onready var troll = $Troll
@onready var strikes_container: HBoxContainer = $CanvasLayer/MarginContainer/HBoxContainer/StrikesContainer
@onready var inspect_button = $CanvasLayer/InspectButton
@onready var eat_button = $CanvasLayer/EatButton
@onready var pass_button = $CanvasLayer/PassButton
@onready var censored_label = $CanvasLayer/CensoredLabel
@onready var dialogue_trigger_point = $DialogueTriggerPoint
@onready var troll_dialogue_bubble = $CanvasLayer/TrollDialogueBubble
@onready var fax_machine = $FaxMachine
@onready var grab_paper_button = $CanvasLayer/GrabPaperButton
@onready var ambience: AudioStreamPlayer = $Ambience
@onready var day_title_label = $CanvasLayer/DayTitleLabel
@onready var dialogue_bubble = $CanvasLayer/DialogueContainer/DialogueBubble

const DECREE_PANEL_SCENE = preload("res://decree_panel.tscn")
const GoatData = preload("res://GoatData.gd")
const BRIDGE_GOER_SCENE = preload("res://bridge_goer.tscn")

var strikes_remaining = 3
var current_goat_data: Dictionary
var current_day = 1
var day_goat_index = 0

enum GameState { NONE, DIALOGUE, WAITING_FOR_INSPECT, WAITING_FOR_DECISION, PAUSED }
var current_state = GameState.NONE

var troll_questions = [ "Who goes there?!", "What's the password?", "State your business!", "You dare cross my bridge?", "Halt! Who goes trip-trapping over my bridge?" ]

func _ready():
	ambience.play()
	inspect_button.pressed.connect(on_inspect_button_pressed)
	eat_button.pressed.connect(on_eat_button_pressed)
	pass_button.pressed.connect(on_pass_button_pressed)
	troll.is_dropping.connect(on_troll_is_dropping)
	
	censored_label.hide()
	troll_dialogue_bubble.hide()
	set_button_visibility(false, false, false)
	update_strikes_ui()
	top_world_material.set_shader_parameter("silhouette_strength", 1.0)
	get_tree().create_timer(1.0).timeout.connect(spawn_character)

func on_troll_is_dropping(duration: float):
	var tween = create_tween().set_parallel()
	tween.tween_property(top_world_material, "shader_parameter/silhouette_strength", 1.0, duration)
	
	var target = troll.get_target()
	if target:
		target.set_silhouette(true)

func set_button_visibility(inspect: bool, eat: bool, pass_btn: bool):
	inspect_button.visible = inspect
	eat_button.visible = eat
	pass_button.visible = pass_btn

func update_strikes_ui():
	var strike_icons = strikes_container.get_children()
	for i in range(strike_icons.size()):
		strike_icons[i].visible = (i < strikes_remaining)

func spawn_character():
	var current_day_goats = GoatData.DAYS_DATA.get(current_day, [])
	if day_goat_index >= current_day_goats.size():
		start_end_of_day_sequence()
		return

	current_goat_data = current_day_goats[day_goat_index]
	day_goat_index += 1

	var new_goer = BRIDGE_GOER_SCENE.instantiate()
	add_child(new_goer)
	new_goer.initialize(current_goat_data, spawn_point_left.position, dialogue_trigger_point.position, bridge_point.position)
	new_goer.action_complete.connect(on_goat_action_complete)
	new_goer.dialogue_trigger_reached.connect(on_goat_reaches_trigger)
	new_goer.final_position_reached.connect(on_goat_reaches_bridge)
	new_goer.timer_ran_out.connect(on_goat_timer_ran_out)
	new_goer.wants_to_speak.connect(on_goat_wants_to_speak)
	troll.set_target(new_goer)

	current_state = GameState.DIALOGUE
	set_button_visibility(false, false, false)

func check_decision(action: String):
	var correct_action = current_goat_data.get("correct_action", "PASS")
	return action == correct_action

func handle_mistake(reason: String):
	if current_state == GameState.PAUSED: return # Prevent multiple mistakes
	current_state = GameState.PAUSED
	get_tree().paused = true # <-- PAUSE THE ENTIRE SCENE TREE

	strikes_remaining -= 1
	update_strikes_ui()
	SoundManager.play("crunch")
	set_button_visibility(false, false, false)
	
	var target = troll.get_target()
	if target:
		target.stop_timer()

	var warning_panel = DECREE_PANEL_SCENE.instantiate()
	# Make the panel process even when the game is paused
	warning_panel.process_mode = Node.PROCESS_MODE_ALWAYS 
	add_child(warning_panel)
	
	var warning_text = "MANDATE VIOLATION\n\nReason: " + reason + "\n\nStrikes Remaining: " + str(strikes_remaining)
	warning_panel.show_decree(warning_text)
	
	warning_panel.mandate_accepted.connect(func():
		get_tree().paused = false # <-- UNPAUSE THE GAME
		if strikes_remaining <= 0:
			get_tree().change_scene_to_file("res://EndScreen.tscn")
		else:
			if target:
				target.depart(true)
			current_state = GameState.NONE
	)

func on_goat_timer_ran_out():
	handle_mistake("Took too long to make a decision.")
	troll.action_pass()
	set_button_visibility(false, false, false)

func on_goat_wants_to_speak(text: String):
	var target = troll.get_target()
	if !target: return

	dialogue_bubble.global_position = target.global_position + Vector2(0, -50)
	dialogue_bubble.text = text
	dialogue_bubble.show()
	get_tree().create_timer(3.0).timeout.connect(func(): dialogue_bubble.hide())

func on_goat_reaches_trigger():
	$Sound/Troll_voice.play()
	var troll_question = troll_questions.pick_random()
	troll_dialogue_bubble.text = troll_question
	troll_dialogue_bubble.show()
	get_tree().create_timer(2.5).timeout.connect(func(): troll_dialogue_bubble.hide())

func on_goat_reaches_bridge():
	$Sound/bleat.play()
	var goat_answer = current_goat_data["dialogue"]
	var target = troll.get_target()
	if target:
		var dialogue_timer = target.show_dialogue(goat_answer)
		await dialogue_timer.timeout
	
	if current_state != GameState.PAUSED:
		current_state = GameState.WAITING_FOR_INSPECT
		set_button_visibility(true, false, true)

func on_goat_action_complete():
	current_state = GameState.NONE
	set_button_visibility(false, false, false)
	get_tree().create_timer(2.0).timeout.connect(spawn_character)

func on_inspect_button_pressed():
	if current_state != GameState.WAITING_FOR_INSPECT: return
	SoundManager.play("ui_click")
	
	if current_goat_data.get("special_rule") == "NO_INSPECT":
		handle_mistake("You were instructed not to inspect this goat.")
	else:
		current_state = GameState.WAITING_FOR_DECISION
		troll.action_peek()
		var target = troll.get_target()
		if target:
			var tween = target.reveal_and_start_timer()
			tween.tween_property(top_world_material, "shader_parameter/silhouette_strength", 0.0, 0.3)
		set_button_visibility(false, true, true)

func on_eat_button_pressed():
	if current_state != GameState.WAITING_FOR_DECISION: return
	
	if check_decision("EAT"):
		SoundManager.play("eat_sound") # Your new correct eat sound
		censored_label.show()
		get_tree().create_timer(0.5).timeout.connect(func(): censored_label.hide())
		troll.action_eat()
		on_goat_action_complete()
	else:
		handle_mistake("Incorrectly ate a goat.")

func on_pass_button_pressed():
	var target = troll.get_target()
	if !target or current_state == GameState.PAUSED: return

	var action = "PASS"
	if check_decision(action):
		SoundManager.play("cha_ching")
		target.depart(true)
		troll.action_pass()
		current_state = GameState.NONE
		set_button_visibility(false, false, false)
	else:
		if current_state == GameState.WAITING_FOR_INSPECT:
			handle_mistake("Incorrectly passed a goat before inspection.")
		else:
			handle_mistake("Incorrectly passed a goat after inspection.")

func start_end_of_day_sequence():
	current_state = GameState.NONE
	set_button_visibility(false, false, false)
	SoundManager.play("fax_noises")
	await SoundManager.sound_players["fax_noises"].finished
	SoundManager.play("printing")
	fax_machine.play("printing")
	fax_machine.animation_finished.connect(on_fax_printed, CONNECT_ONE_SHOT)

func on_fax_printed():
	fax_machine.play("completed") 
	grab_paper_button.show()
	grab_paper_button.pressed.connect(show_next_decree, CONNECT_ONE_SHOT)

func show_next_decree():
	SoundManager.play("paper_grab")
	grab_paper_button.hide()
	current_day += 1
	
	if not GoatData.DAYS_DATA.has(current_day):
		get_tree().change_scene_to_file("res://EndScreen.tscn")
		return

	var decree_panel = DECREE_PANEL_SCENE.instantiate()
	add_child(decree_panel)
	var next_decree_text = GoatData.DECREE_TEXTS[current_day]
	decree_panel.show_decree(next_decree_text)
	decree_panel.mandate_accepted.connect(start_new_day)

func start_new_day():
	fax_machine.play("idle")
	day_goat_index = 0
	
	# Update the day title UI
	var decree_title = GoatData.DECREE_TITLES[current_day]
	day_title_label.text = "DAY " + str(current_day) + " - " + decree_title
	
	spawn_character()
