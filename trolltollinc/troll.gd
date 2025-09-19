# Troll.gd
extends Sprite2D

# This will hold a reference to the current character on the bridge.
var current_target = null

# This function will be called by the Main script to tell the troll who to target.
func set_target(bridge_goer):
	current_target = bridge_goer
	print("Troll has a new target: ", current_target.name)

# This is the function the EAT button will call.
func on_eat_pressed():
	# First, check if there is actually a target.
	if current_target:
		print("ATE ", current_target.name)
		# Destroy the target.
		current_target.queue_free()
		# Clear the target so we can't eat them again.
		current_target = null

# This is the function the PASS button will call.
func on_pass_pressed():
	if current_target:
		print("PASSED ", current_target.name)
		current_target.queue_free()
		current_target = null
