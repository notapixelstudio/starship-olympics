extends Panel


func _on_Description_item_rect_changed():
	$Description.rect_size.x = 0
	yield(get_tree(), "idle_frame")
	rect_min_size.x = $Description.rect_size.x
	
