# DecreePanel.gd
extends Control

signal mandate_accepted

@onready var decree_text = $DecreeText
@onready var accept_button = $AcceptButton

func _ready():
	accept_button.pressed.connect(on_accept_pressed)

func show_decree(text: String):
	decree_text.text = text
	# The tween for the paper slide-in effect
	position.y = get_viewport_rect().size.y
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "position:y", 0, 0.5)
	show()

func set_accept_button_text(text: String):
	accept_button.text = text

func on_accept_pressed():
	SoundManager.play("drumroll")
	mandate_accepted.emit()
	queue_free() # The panel destroys itself after being accepted.
