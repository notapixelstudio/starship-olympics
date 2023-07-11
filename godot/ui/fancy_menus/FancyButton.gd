extends TextureButton
class_name FancyButton
## A special [TextureButton] that grows and glows when focused.

func _ready():
	pivot_offset = size / 2.0
	_blur()
	

func _focus():
	modulate = Color(1.16, 1.16, 1.16)
	$AnimationPlayer.play("Grow")

func _blur():
	modulate = Color(0.45, 0.45, 0.45)
	$AnimationPlayer.play("Shrink")
	
func _on_FancyButton_focus_entered():
	_focus()
	
func _on_FancyButton_focus_exited():
	_blur()
	
