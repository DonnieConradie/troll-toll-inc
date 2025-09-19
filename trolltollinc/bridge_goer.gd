# BridgeGoer.gd
extends CharacterBody2D

# --- Signals ---
# This signal will be emitted when the timer runs out.
signal time_ran_out

# --- Components ---
# We link the nodes from the scene tree to variables in our script.
@onready var sprite = $Sprite2D
@onready var timer = $Timer
@onready var timer_label = $Label

# --- Properties ---
# How long this character will wait on the bridge.
var wait_duration = 10.0

func _ready():
	# Configure the timer when the scene starts.
	timer.wait_time = wait_duration
	timer.one_shot = true # It only runs once.
	# Connect the timer's "timeout" signal to a function we will create.
	timer.timeout.connect(on_timer_timeout)
	
	# Start the timer!
	timer.start()
	
	# Set the initial text for the label.
	timer_label.text = str(wait_duration)

func _process(delta):
	# This function runs every frame. We'll update the label here.
	# `%.1f` formats the number to show only one decimal place.
	timer_label.text = "%.1f" % timer.time_left

# This function is called automatically when the Timer node finishes.
func on_timer_timeout():
	print("Timer ran out! The character should leave now.")
	# We emit our custom signal to let the Main scene know what happened.
	time_ran_out.emit()
	# Remove the character from the game.
	queue_free()
