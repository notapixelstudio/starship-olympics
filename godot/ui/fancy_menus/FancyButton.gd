extends TextureButton
class_name FancyButton
## A special [TextureButton] that grows and glows when focused.

func _ready():
	pivot_offset = size / 2.0
	blur()
	

func focus():
	modulate = Color(1.16, 1.16, 1.16)
	$AnimationPlayer.play("Grow")

func blur():
	modulate = Color(0.4, 0.4, 0.4)
	$AnimationPlayer.play("Shrink")
	
func _on_FancyButton_focus_entered():
	focus()
	
func _on_FancyButton_focus_exited():
	blur()
	
