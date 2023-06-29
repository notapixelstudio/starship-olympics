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
	
func isolate():
	focus_neighbour_top = get_path()
	focus_neighbour_bottom = get_path()
	focus_neighbour_left = get_path()
	focus_neighbour_right = get_path()
	
func _on_FancyButton_focus_entered():
	focus()
	
func _on_FancyButton_focus_exited():
	blur()
	
