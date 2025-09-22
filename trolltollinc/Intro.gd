# Intro.gd
extends Node2D

@onready var audio_player = $AudioStreamPlayer
@onready var skip_button = $SkipButton
@onready var transition_label = $TransitionLabel

const GoatData = preload("res://GoatData.gd")
const DECREE_PANEL_SCENE = preload("res://decree_panel.tscn")

var has_skipped = false
var intro_finished = false

func _ready():
	skip_button.pressed.connect(on_skip_pressed)
	
	transition_label.modulate.a = 0.0
	play_intro_sequence()

func play_intro_sequence():
	# This function's only job is to play the visuals and the audio.
	# It no longer calls show_first_decree().
	
	await get_tree().create_timer(1.0).timeout
	if has_skipped: return
	
	audio_player.play()
	
	var tween = create_tween().set_parallel()
	tween.tween_property(transition_label, "modulate:a", 1.0, 1.0)
	await tween.finished
	if has_skipped: return
	
	await get_tree().create_timer(1.5).timeout
	if has_skipped: return
	
	var tween2 = create_tween()
	tween2.tween_property(transition_label, "modulate:a", 0.0, 1.0)
	await tween2.finished
	# The function now ends here. The 'finished' signal will handle the next step.

func on_skip_pressed():
	if has_skipped: return
	has_skipped = true
	audio_player.stop()
	
	var tweens = get_tree().get_nodes_in_group("tweens")
	for t in tweens:
		t.kill()
		
	show_first_decree()

func show_first_decree():
	if intro_finished: return
	intro_finished = true
	
	skip_button.hide()
	transition_label.hide()
	
	var decree_panel = DECREE_PANEL_SCENE.instantiate()
	add_child(decree_panel)
	
	var decree_text = GoatData.DECREE_TEXTS[1]
	decree_panel.show_decree(decree_text)
	
	decree_panel.mandate_accepted.connect(go_to_main_game)

func go_to_main_game():
	get_tree().change_scene_to_file("res://main.tscn")

func _on_audio_stream_player_finished():
	# This function now correctly checks if the player has already skipped.
	if has_skipped:
		return
	
	show_first_decree()
