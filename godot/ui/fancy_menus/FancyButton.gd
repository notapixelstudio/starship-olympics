extends TextureButton

func _ready():
	rect_pivot_offset = rect_size / 2.0
	blur()
	
func focus():
	modulate = Color(1.17, 1.17, 1.17)
	$AnimationPlayer.play("Grow")

func blur():
	modulate = Color(0.45, 0.45, 0.45)
	$AnimationPlayer.play("Shrink")
	
func _on_FancyButton_focus_entered():
	focus()
	
func _on_FancyButton_focus_exited():
	blur()
	
