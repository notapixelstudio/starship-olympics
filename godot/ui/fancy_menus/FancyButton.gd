extends TextureButton
class_name FancyButton
## A special [TextureButton] that grows and glows when focused.

var _silent := true

func _ready():
	pivot_offset = size / 2.0
	blur()
	
	# start without sound to disable audio feedback on appearing
	await get_tree().process_frame
	_silent = false
	
func focus():
	modulate = Color(1, 1, 1)
	z_index = 10
	$AnimationPlayer.play("Grow")
	if not _silent:
		%AudioStreamPlayer2D.play()
	
func blur():
	modulate = Color(0.3, 0.3, 0.3)
	z_index = 0
	$AnimationPlayer.play("Shrink")
	
func _on_FancyButton_focus_entered():
	focus()
	
func _on_FancyButton_focus_exited():
	blur()
	
