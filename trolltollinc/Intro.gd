# Intro.gd
extends Node2D

@onready var audio_player = $AudioStreamPlayer
@onready var skip_button = $SkipButton
@onready var transition_label: Label = $TransitionLabel
@onready var hover: AudioStreamPlayer = $Hover
@onready var click: AudioStreamPlayer = $Click

const GoatData = preload("res://GoatData.gd")
const DECREE_PANEL_SCENE = preload("res://decree_panel.tscn")

const WELCOME_LETTER_TEXT = """
WELCOME, NEW HIRE\n
Your function is to regulate bridge traffic according to daily mandates.\n
Review your mandates carefully. Make three mistakes, and you will be terminated.\n
Sign below to accept the terms.
"""

var has_skipped = false
var intro_finished = false

func _ready():
	SoundManager.stop_all_music()
	skip_button.pressed.connect(on_skip_pressed)
	play_intro_sequence()
	transition_label.modulate.a = 0.0
	audio_player.play()

func play_intro_sequence():
	skip_button.show()
	transition_label.text = "DAY 1"
	
	# Wait 1 second before starting
	await get_tree().create_timer(1.0).timeout
	if has_skipped: return
	
	# Fade in the "DAY 1" text (takes 1 second)
	var tween = create_tween()
	tween.tween_property(transition_label, "modulate:a", 1.0, 1.0)
	await tween.finished
	if has_skipped: return
	
	# Hold for 2 seconds
	await get_tree().create_timer(2.0).timeout
	if has_skipped: return
	
	# Fade out the "DAY 1" text (takes 1 second)
	var tween2 = create_tween()
	tween2.tween_property(transition_label, "modulate:a", 0.0, 1.0)
	await tween2.finished

func on_skip_pressed():
	# If we skip, stop the fax sound and immediately show the letter
	audio_player.stop()
	show_welcome_letter()

func _on_audio_stream_player_finished():
	# This is called ONLY when the fax sound finishes playing naturally
	show_welcome_letter()

func show_welcome_letter():
	# This function should only ever run once.
	if get_tree().get_nodes_in_group("decree_panel").size() > 0:
		return
		
	skip_button.hide()

	var welcome_panel = DECREE_PANEL_SCENE.instantiate()
	welcome_panel.add_to_group("decree_panel")
	add_child(welcome_panel)
	welcome_panel.show_decree(WELCOME_LETTER_TEXT)
	welcome_panel.set_accept_button_text("Sign & Accept Employment")
	
	welcome_panel.mandate_accepted.connect(show_first_decree)

func show_first_decree():
	var decree_panel = DECREE_PANEL_SCENE.instantiate()
	add_child(decree_panel)
	
	var decree_text = GoatData.DECREE_TEXTS[1]
	decree_panel.show_decree(decree_text)
	decree_panel.enable_drum_roll()
	
	decree_panel.mandate_accepted.connect(go_to_main_game)

func go_to_main_game():
	get_tree().change_scene_to_file("res://main.tscn")

func _on_mouse_entered() -> void:
	hover.play()

func _on_button_pressed() -> void:
	click.play()
