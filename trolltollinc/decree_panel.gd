# DecreePanel.gd
extends Control

signal mandate_accepted

@onready var decree_text: Label = $DecreeText
@onready var accept_button: Button = $AcceptButton
@onready var click: AudioStreamPlayer = $Click
@onready var hover: AudioStreamPlayer = $Hover

var use_drum_roll_sound = false

func _ready():
	SoundManager.play("paper_grab")
	accept_button.pressed.connect(on_accept_pressed)

func show_decree(text: String):
	decree_text.text = text
	position.y = get_viewport_rect().size.y
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "position:y", 0, 0.5)
	show()

func set_accept_button_text(text: String):
	accept_button.text = text

func enable_drum_roll():
	use_drum_roll_sound = true

func on_accept_pressed():
	if use_drum_roll_sound:
		SoundManager.play("drum_roll")
	else:
		SoundManager.play("ui_click")
	
	mandate_accepted.emit()
	queue_free()

func _on_accept_button_mouse_entered() -> void:
	hover.play()

func _on_accept_button_pressed() -> void:
	click.play()
