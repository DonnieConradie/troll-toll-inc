# Main.gd
extends Node2D


@onready var spawn_point = $SpawnPoint
@onready var troll = $Troll
@onready var hunger_bar: TextureProgressBar = $CanvasLayer/MarginContainer/HBoxContainer/HBoxContainer2/HungerBar
@onready var scare_bar: TextureProgressBar = $CanvasLayer/MarginContainer/HBoxContainer/HBoxContainer2/ScareBar
@onready var gold_label: Label = $CanvasLayer/MarginContainer/HBoxContainer/VBoxContainer/GoldLabel
@onready var inspect_button = $CanvasLayer/InspectButton
@onready var eat_button = $CanvasLayer/EatButton
@onready var pass_button = $CanvasLayer/PassButton
@onready var censored_label = $CanvasLayer/CensoredLabel

const BRIDGE_GOER_SCENE = preload("res://bridge_goer.tscn")

var hunger = 100
var gold = 0
var scare_factor = 50

enum GameState { WAITING_FOR_INSPECT, WAITING_FOR_DECISION }
var current_state = GameState.WAITING_FOR_INSPECT

func _ready():
	inspect_button.pressed.connect(on_inspect_button_pressed)
	eat_button.pressed.connect(on_eat_button_pressed)
	pass_button.pressed.connect(on_pass_button_pressed)
	censored_label.hide()
	eat_button.disabled = true
	pass_button.disabled = true
	
	update_ui()
	spawn_character()


func update_ui():
	hunger_bar.value = hunger
	scare_bar.value = scare_factor
	gold_label.text = "%s" % gold

func spawn_character():
	var new_goer = BRIDGE_GOER_SCENE.instantiate()
	new_goer.position = spawn_point.position
	add_child(new_goer)
	troll.set_target(new_goer)
	
	current_state = GameState.WAITING_FOR_INSPECT
	inspect_button.disabled = false
	eat_button.disabled = true
	pass_button.disabled = true
	new_goer.set_silhouette(true)

func on_inspect_button_pressed():
	if current_state == GameState.WAITING_FOR_INSPECT:
		current_state = GameState.WAITING_FOR_DECISION
		
		troll.action_peek()
		
		var target = troll.get_target()
		if target:
			target.set_silhouette(false)
		
		inspect_button.disabled = true
		eat_button.disabled = false
		pass_button.disabled = false

func on_eat_button_pressed():
	if current_state == GameState.WAITING_FOR_DECISION:
		hunger = clamp(hunger + 20, 0, 100)
		scare_factor = clamp(scare_factor + 15, 0, 100)
		update_ui()
		
		censored_label.show()
		get_tree().create_timer(0.5).timeout.connect(func(): censored_label.hide())
		
		troll.action_eat()
		get_tree().create_timer(1.0).timeout.connect(spawn_character)

func on_pass_button_pressed():
	if current_state == GameState.WAITING_FOR_DECISION:
		gold += 10
		scare_factor = clamp(scare_factor - 10, 0, 100)
		update_ui()
		
		troll.action_pass()
		get_tree().create_timer(1.0).timeout.connect(spawn_character)
