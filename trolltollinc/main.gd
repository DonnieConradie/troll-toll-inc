# Main.gd
extends Node2D

@onready var top_world_material = $TopWorld.material
@onready var spawn_point_left: Marker2D = $TopWorld/SpawnPointLeft
@onready var bridge_point: Marker2D = $TopWorld/BridgePoint
@onready var exit_point_right: Marker2D = $TopWorld/ExitPointRight
@onready var troll = $Troll
@onready var strikes_container = $CanvasLayer/MainGameUI/MarginContainer/HBoxContainer/StrikesContainer
@onready var day_title_label = $CanvasLayer/MainGameUI/DayTitleLabel
@onready var view_mandate_button: Button = $CanvasLayer/MainGameUI/ViewMandateButton
@onready var eat_button: Button = $CanvasLayer/MainGameUI/EatButton
@onready var pass_button: Button = $CanvasLayer/MainGameUI/PassButton
@onready var inspect_button: Button = $CanvasLayer/MainGameUI/InspectButton
@onready var censored_label = $CanvasLayer/MainGameUI/CensoredLabel
@onready var dialogue_trigger_point = $DialogueTriggerPoint
@onready var troll_dialogue_bubble = $CanvasLayer/MainGameUI/TrollDialogueBubble
@onready var dialogue_bubble = $CanvasLayer/MainGameUI/DialogueContainer/DialogueBubble
@onready var fax_machine = $FaxMachine
@onready var grab_paper_button = $CanvasLayer/MainGameUI/GrabPaperButton
@onready var ambience: AudioStreamPlayer = $Ambience
@onready var main_game_ui = $CanvasLayer/MainGameUI
@onready var hover: AudioStreamPlayer = $Sound/Hover
@onready var click: AudioStreamPlayer = $Sound/Click
@onready var bite: AudioStreamPlayer = $Sound/Bite
@onready var pause_menu: Control = $"CanvasLayer/Pause menu"
@onready var gold_label: Label = $CanvasLayer/MainGameUI/MarginContainer/HBoxContainer/VBoxContainer/GoldLabel


const DECREE_PANEL_SCENE = preload("res://decree_panel.tscn")
const GoatData = preload("res://GoatData.gd")
const BRIDGE_GOER_SCENE = preload("res://bridge_goer.tscn")

var strikes_remaining = 3
var current_goat_data: Dictionary
var current_day = 1
var day_goat_index = 0
var gold = 0 

enum GameState { NONE, DIALOGUE, WAITING_FOR_INSPECT, WAITING_FOR_DECISION, PAUSED }
var current_state = GameState.NONE
var pre_pause_state = GameState.NONE

var troll_questions = [ "Who goes there?!", "What's the password?", "State your business!", "You dare cross my bridge?", "Halt! Who goes trip-trapping over my bridge?" ]
var troll_reminder_lines = [
	"Right, new day. Don't forget about those endangered one-horned goats...",
	"Another day, another decree. Remember the one-horn rule, management is watching.",
	"Okay, focus. That one-horn policy is still in effect. No inspections."
]

func _ready():
	ambience.play()
	SoundManager.play_game_music()
	
	inspect_button.pressed.connect(on_inspect_button_pressed)
	eat_button.pressed.connect(on_eat_button_pressed)
	pass_button.pressed.connect(on_pass_button_pressed)
	troll.is_dropping.connect(on_troll_is_dropping)
	view_mandate_button.pressed.connect(on_view_mandate_pressed)
	
	update_strikes_ui()
	update_gold_ui()
	
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

func update_ui_state():
	match current_state:
		GameState.WAITING_FOR_INSPECT:
			set_button_visibility(true, false, true)
		GameState.WAITING_FOR_DECISION:
			set_button_visibility(false, true, true)
		_: # This default case covers NONE, DIALOGUE, and PAUSED states.
			set_button_visibility(false, false, false)

func set_button_visibility(inspect: bool, eat: bool, pass_btn: bool):
	inspect_button.visible = inspect
	eat_button.visible = eat
	pass_button.visible = pass_btn

func update_strikes_ui():
	var strike_icons = strikes_container.get_children()
	for i in range(strike_icons.size()):
		strike_icons[i].visible = (i < strikes_remaining)

func update_gold_ui():
	gold_label.text = "R" + str(gold)

func spawn_character():
	var current_day_goats = GoatData.DAYS_DATA.get(current_day, [])
	if day_goat_index >= current_day_goats.size():
		start_end_of_day_sequence()
		return

	current_goat_data = current_day_goats[day_goat_index]
	day_goat_index += 1

	var new_goer = BRIDGE_GOER_SCENE.instantiate()
	add_child(new_goer)
	if current_day == 7:
		new_goer.wait_duration = 8.0
	new_goer.initialize(current_goat_data, spawn_point_left.position, dialogue_trigger_point.position, bridge_point.position)
	new_goer.action_complete.connect(on_goat_action_complete)
	new_goer.dialogue_trigger_reached.connect(on_goat_reaches_trigger)
	new_goer.final_position_reached.connect(on_goat_reaches_bridge)
	new_goer.timer_ran_out.connect(on_goat_timer_ran_out)
	new_goer.wants_to_speak.connect(on_goat_wants_to_speak)
	troll.set_target(new_goer)

	current_state = GameState.DIALOGUE
	set_button_visibility(false, false, false)

func on_goat_wants_to_speak(text: String):
	var target = troll.get_target()
	if !target: return
	dialogue_bubble.global_position = target.global_position + Vector2(0, -50)
	dialogue_bubble.text = text
	dialogue_bubble.show()
	get_tree().create_timer(3.0).timeout.connect(func(): 
		if dialogue_bubble: 
			dialogue_bubble.hide()
	)

func handle_mistake(reason: String):
	await get_tree().create_timer(1.0).timeout
	if get_tree().paused: return
	
	set_button_visibility(false, false, false)
	get_tree().paused = true
	main_game_ui.hide()
	
	strikes_remaining -= 1
	update_strikes_ui()
	SoundManager.play("crunch")
	
	var target = troll.get_target()
	if target:
		target.stop_timer()

	var warning_panel = DECREE_PANEL_SCENE.instantiate()
	warning_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(warning_panel)
	
	var warning_text = "MANDATE VIOLATION\n\nReason: " + reason + "\n\nStrikes Remaining: " + str(strikes_remaining)
	warning_panel.show_decree(warning_text)
	
	warning_panel.mandate_accepted.connect(func():
		get_tree().paused = false
		main_game_ui.show()
		if strikes_remaining <= 0:
			SoundManager.stop_all_music()
			get_tree().change_scene_to_file("res://end_screen.tscn")
		else:
			# --- THIS IS THE KEY CHANGE ---
			# Only depart the goat if it still exists.
			# If the mistake was an illegal eat, the target will be null here.
			if target:
				target.depart(true)
			else:
				# If the target is null (because we ate it), we still need to
				# trigger the cooldown for the next goat to spawn.
				on_goat_action_complete()

			current_state = GameState.NONE
			re_evaluate_ui_state()
	)

func on_eat_button_pressed():
	if current_state != GameState.WAITING_FOR_DECISION: return
	
	# --- THIS IS THE NEW LOGIC ---
	# Your sound plays, and we immediately perform the visual action.
	bite.play()
	censored_label.show()
	get_tree().create_timer(0.5).timeout.connect(func(): censored_label.hide())
	troll.action_eat() # This will queue_free the goat
	
	# We hide the buttons immediately as the action is taken.
	set_button_visibility(false, false, false)
	
	# We wait for the troll's animation to finish before checking the rules.
	await troll.animation_finished
	
	if current_goat_data["correct_action"] == "EAT":
		# The decision was correct. The goat is already gone.
		# We just need to start the cooldown for the next goat.
		on_goat_action_complete()
	else:
		var reason = current_goat_data.get("failure_reason", "This goat should have been PASSED.")
		handle_mistake(reason)

func on_pass_button_pressed():
	var target = troll.get_target()
	if !target or current_state == GameState.PAUSED: return

	# --- THIS IS THE NEW LOGIC ---
	var was_inspected = (current_state == GameState.WAITING_FOR_DECISION)
	
	if was_inspected:
		# Only award gold if the goat was inspected
		gold += 10
		update_gold_ui() # A new, targeted function for clarity
		SoundManager.play("cha_ching")
	else:
		# If not inspected, just play a simple click sound
		SoundManager.play("ui_click")

	var is_correct = (current_goat_data["correct_action"] == "PASS")
	
	if is_correct:
		target.depart(true)
		troll.action_pass()
		current_state = GameState.NONE
		set_button_visibility(false, false, false)
	else:
		if was_inspected:
			var reason = current_goat_data.get("failure_reason", "This goat should have been EATEN.")
			handle_mistake(reason)

func on_view_mandate_pressed():
	# We no longer check the state here. We just check if a panel is already open.
	if get_tree().paused: return
		
	get_tree().paused = true
	main_game_ui.hide()
	set_button_visibility(false, false, false)
	
	var decree_panel = DECREE_PANEL_SCENE.instantiate()
	decree_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(decree_panel)
	
	var decree_text = GoatData.DECREE_TEXTS[current_day]
	decree_panel.show_decree(decree_text)
	decree_panel.set_accept_button_text("Got it")
	
	decree_panel.mandate_accepted.connect(func():
		get_tree().paused = false
		main_game_ui.show()
		# When the panel closes, re-evaluate everything.
		re_evaluate_ui_state()
	)


func re_evaluate_ui_state():
	var target = troll.get_target()
	
	# Rule 1: Is there a goat on the bridge AND is it in the WAITING state?
	if !target or target.current_state != BridgeGoer.State.WAITING:
		# If there is no goat, OR the goat is not idling, show nothing.
		current_state = GameState.NONE
		set_button_visibility(false, false, false)
		return

	# Rule 2: If there is an idling goat, what is the troll's state?
	if troll.animation == "peek":
		current_state = GameState.WAITING_FOR_DECISION
		set_button_visibility(false, true, true)
	else:
		current_state = GameState.WAITING_FOR_INSPECT
		set_button_visibility(true, false, true)

func on_goat_timer_ran_out():
	handle_mistake("Took too long to make a decision.")
	troll.action_pass()

func on_goat_reaches_trigger():
	$Sound/Troll_voice.play()
	var troll_question = troll_questions.pick_random()
	troll_dialogue_bubble.text = troll_question
	troll_dialogue_bubble.show()
	get_tree().create_timer(3.0).timeout.connect(func(): troll_dialogue_bubble.hide())

func on_goat_reaches_bridge():
	$Sound/bleat.play()
	var goat_answer = current_goat_data["dialogue"]
	var target = troll.get_target()
	if target:
		var dialogue_timer = target.show_dialogue(goat_answer)
		await get_tree().create_timer(0.5).timeout
	
	if current_state != GameState.PAUSED:
		current_state = GameState.WAITING_FOR_INSPECT
		set_button_visibility(true, false, true)

func on_goat_action_complete():
	current_state = GameState.NONE
	re_evaluate_ui_state() 
	get_tree().create_timer(0.5).timeout.connect(spawn_character)

func on_inspect_button_pressed():
	if current_state != GameState.WAITING_FOR_INSPECT: return
	SoundManager.play("ui_click")
	
	if current_goat_data.get("special_rule") == "NO_INSPECT":
		var reason = current_goat_data.get("failure_reason", "This goat should not have been inspected.")
		handle_mistake(reason)
	else:
		current_state = GameState.WAITING_FOR_DECISION
		troll.action_peek()
		var target = troll.get_target()
		if target:
			var tween = target.reveal_and_start_timer()
			tween.tween_property(top_world_material, "shader_parameter/silhouette_strength", 0.0, 0.3)
		set_button_visibility(false, true, true)

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
	main_game_ui.hide()
	current_day += 1
	
	# --- THIS IS THE NEW LOGIC ---
	if current_day == 2:
		# Special case for the transition to Day 2
		var clarification_panel = DECREE_PANEL_SCENE.instantiate()
		add_child(clarification_panel)
		clarification_panel.show_decree(GoatData.CLARIFICATION_TEXT)
		clarification_panel.set_accept_button_text("Understood")
		
		# When the clarification is accepted, THEN we show the real mandate
		clarification_panel.mandate_accepted.connect(func():
			var decree_panel = DECREE_PANEL_SCENE.instantiate()
			add_child(decree_panel)
			var next_decree_text = GoatData.DECREE_TEXTS[current_day]
			decree_panel.show_decree(next_decree_text)
			decree_panel.enable_drum_roll() # This one leads to a new day
			
			decree_panel.mandate_accepted.connect(func():
				main_game_ui.show()
				start_new_day()
			)
		)
	else:
		# Normal logic for all other days (Day 3, 4, 5, etc.)
		if not GoatData.DAYS_DATA.has(current_day):
			SoundManager.stop_all_music()
			get_tree().change_scene_to_file("res://WinScreen.tscn")
			return

		var decree_panel = DECREE_PANEL_SCENE.instantiate()
		add_child(decree_panel)
		var next_decree_text = GoatData.DECREE_TEXTS[current_day]
		decree_panel.show_decree(next_decree_text)
		decree_panel.enable_drum_roll()
		
		decree_panel.mandate_accepted.connect(func():
			main_game_ui.show()
			start_new_day()
		)

func start_new_day():
	fax_machine.play("idle")
	$Sound/Drumroll.play()
	day_goat_index = 0
	
	var decree_title = GoatData.DECREE_TITLES[current_day]
	day_title_label.text = "DAY " + str(current_day) + " - " + decree_title
	
	# --- THIS IS THE NEW LOGIC ---
	# Check if it's a day where a reminder is needed.
	if current_day == 3 or current_day == 5:
		# Pick a random reminder and show it in the troll's bubble.
		var reminder_text = troll_reminder_lines.pick_random()
		troll_dialogue_bubble.text = reminder_text
		troll_dialogue_bubble.show()
		
		# Wait for 4 seconds so the player has time to read it.
		await get_tree().create_timer(4.0).timeout
		troll_dialogue_bubble.hide()

	# The rest of the function proceeds as normal.
	spawn_character()


func _on_mouse_entered() -> void:
	hover.play()


func _on_button_pressed() -> void:
	click.play()


func _unhandled_input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		$Sound/bleat.play()
		if not get_tree().paused:
			get_tree().paused = true
			pause_menu.show()

func _on_continue_pressed() -> void:
	get_tree().paused = false
	pause_menu.hide()
	$Sound/bleat.play()


func _on_quit_pressed() -> void:
	get_tree().paused = false # Always unpause before changing scenes
	get_tree().change_scene_to_file("res://main_menu.tscn")
