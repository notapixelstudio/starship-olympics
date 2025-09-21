extends Screen

@export var next_screen_scene : PackedScene

@export var bgm : AudioStream

func _ready():
	DeeJay.play(bgm)

func _on_press_any_key_any_key_pressed() -> void:
	next.emit(next_screen_scene.instantiate())
