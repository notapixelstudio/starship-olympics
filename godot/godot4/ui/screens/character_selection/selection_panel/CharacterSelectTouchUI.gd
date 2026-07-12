extends CanvasLayer

signal prev_pressed
signal next_pressed
signal action_pressed

func _ready() -> void:
	visible = DisplayServer.is_touchscreen_available() or OS.has_feature("mobile")
	layer = 12
	%PrevButton.pressed.connect(prev_pressed.emit)
	%NextButton.pressed.connect(next_pressed.emit)
	%ActionButton.pressed.connect(action_pressed.emit)

func set_mode(mode: String) -> void:
	if not (DisplayServer.is_touchscreen_available() or OS.has_feature("mobile")):
		visible = false
		return
	visible = mode != "hidden"
	match mode:
		"join":
			%HintLabel.text = "TAP JOIN TO PLAY"
			%ActionButton.text = "JOIN"
			%ActionButton.disabled = false
			%PrevButton.disabled = true
			%NextButton.disabled = true
		"browse":
			%HintLabel.text = "PICK YOUR SHIP"
			%ActionButton.text = "SELECT"
			%ActionButton.disabled = false
			%PrevButton.disabled = false
			%NextButton.disabled = false
		"hidden", _:
			visible = false
