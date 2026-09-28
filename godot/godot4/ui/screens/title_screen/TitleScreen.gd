extends Screen

@export var next_screen_scene : PackedScene

@export var bgm : AudioStream

func _ready():
	var screen_width = ProjectSettings.get('display/window/size/viewport_width.mobile') if Utils.is_mobile_touch_device() else ProjectSettings.get('display/window/size/viewport_width')
	%Offset.position.x = screen_width / 2
	DeeJay.play(bgm)

func _on_press_any_key_any_key_pressed() -> void:
	%AnimationPlayer.stop()
	next.emit(next_screen_scene.instantiate())


func _on_animaton_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == 'fade_in':
		%AnimationPlayer.play('wobble')
