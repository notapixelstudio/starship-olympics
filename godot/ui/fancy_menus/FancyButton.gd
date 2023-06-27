extends TextureButton

func _ready():
	rect_pivot_offset = rect_size / 2.0
	blur()
	
func focus():
	self_modulate = Color(1.2, 1.2, 1.2)
	$AnimationPlayer.play("Grow")

func blur():
	self_modulate = Color(0.4, 0.4, 0.4)
	$AnimationPlayer.play("Shrink")
	
func _on_FancyButton_focus_entered():
	focus()
	
func _on_FancyButton_focus_exited():
	blur()
	
