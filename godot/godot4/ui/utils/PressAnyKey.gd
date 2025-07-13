extends Label

signal any_key_pressed

func _ready() -> void:
	set_process_unhandled_input(false)

func enable():
	set_process_unhandled_input(true)
	%ContinueAnimationPlayer.play("blink")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventJoypadButton or event is InputEventKey:
		any_key_pressed.emit()
		set_process_unhandled_input(false)
 
