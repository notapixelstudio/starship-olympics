signal done

func _on_area_2d_body_entered(body: Node2D) -> void:
	var levels = Utils.list_levels(1, 'pve')
	if body is Ship:
		Events.level_selected.emit(levels[0]['scene'], [] as Array[String])
		done.emit()
