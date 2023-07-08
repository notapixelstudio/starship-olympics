extends TextureButton

func _ready():
	pivot_offset = size / 2.0
	blur()
	
func focus():
	modulate = Color(1.16, 1.16, 1.16)
	$AnimationPlayer.play("Grow")

func blur():
	modulate = Color(0.45, 0.45, 0.45)
	$AnimationPlayer.play("Shrink")
	
func isolate():
	focus_neighbor_top = get_path()
	focus_neighbor_bottom = get_path()
	focus_neighbor_left = get_path()
	focus_neighbor_right = get_path()
	
func _on_FancyButton_focus_entered():
	focus()
	
func _on_FancyButton_focus_exited():
	blur()
	
