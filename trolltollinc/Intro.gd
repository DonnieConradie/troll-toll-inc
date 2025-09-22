# Intro.gd
extends Node2D

@onready var audio_player = $AudioStreamPlayer
@onready var skip_button = $SkipButton
@onready var transition_label = $TransitionLabel

const GoatData = preload("res://GoatData.gd")
const DECREE_PANEL_SCENE = preload("res://decree_panel.tscn")

var has_skipped = false

func _ready():
	skip_button.pressed.connect(on_skip_pressed)
	transition_label.modulate.a = 0.0
	
	play_intro_sequence()

func play_intro_sequence():
	await get_tree().create_timer(3.0).timeout
	# Fade in "DAY 1" text
	var tween = create_tween().set_parallel()
	tween.tween_property(transition_label, "modulate:a", 1.0, 1.0)
	audio_player.play()
	
	await tween.finished
	if has_skipped: return
	
	# Hold
	await get_tree().create_timer(2.0).timeout
	if has_skipped: return
	
	# Fade out "DAY 1" text
	var tween2 = create_tween()
	tween2.tween_property(transition_label, "modulate:a", 0.0, 1.0)
	await tween2.finished
	if has_skipped: return

func on_skip_pressed():
	if has_skipped: return
	has_skipped = true
	# Stop all animations and sounds and go straight to the decree
	audio_player.stop()
	get_tree().get_nodes_in_group("tweens").map(func(t): t.kill()) # Kills running tweens
	show_first_decree()

func show_first_decree():
	skip_button.hide()
	transition_label.hide()
	
	var decree_panel = DECREE_PANEL_SCENE.instantiate()
	add_child(decree_panel)
	
	var decree_text = GoatData.DECREE_TEXTS[1]
	decree_panel.show_decree(decree_text)
	
	decree_panel.mandate_accepted.connect(go_to_main_game)

func go_to_main_game():
	get_tree().change_scene_to_file("res://main.tscn")

func _on_audio_stream_player_finished() -> void:
	show_first_decree()
