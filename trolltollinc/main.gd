# Main.gd
extends Node2D

# --- Components ---
@onready var spawn_point = $SpawnPoint
@onready var troll = $Troll # Get a reference to our Troll node.

# --- UI Components ---
# We need to get the buttons from the CanvasLayer.
@onready var eat_button = $CanvasLayer/EatButton
@onready var pass_button = $CanvasLayer/PassButton

# --- Scene Preloads ---
const BRIDGE_GOER_SCENE = preload("res://bridge_goer.tscn")

func _ready():
	# --- Connect Signals ---
	# Connect the "pressed" signal from each button to the troll's functions.
	# When EatButton is pressed, it will call the troll's on_eat_pressed function.
	eat_button.pressed.connect(troll.on_eat_pressed)
	# When PassButton is pressed, it will call the troll's on_pass_pressed function.
	pass_button.pressed.connect(troll.on_pass_pressed)
	
	# Spawn the first character.
	spawn_character()

func spawn_character():
	print("Spawning a new character...")
	var new_goer = BRIDGE_GOER_SCENE.instantiate()
	new_goer.position = spawn_point.position
	add_child(new_goer)
	
	# --- CRITICAL STEP ---
	# Tell the troll about the new character!
	troll.set_target(new_goer)
