extends Screen

@export var next_screen_scene : PackedScene

@export var bgm : AudioStream

func _ready():
	DeeJay.play(bgm)
	await get_tree().process_frame
	var press_any = find_child("PressAnyKey", true, false)
	if press_any and press_any.has_method("enable"):
		press_any.enable()

func _on_press_any_key_any_key_pressed() -> void:
	next.emit(next_screen_scene.instantiate())
