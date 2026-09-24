extends Button

signal selected(data)

var _data

func set_data(v) -> void:
	_data = v
	text = _data['minigame'].title.to_upper() + '  '
	%Icon.texture = _data['minigame'].icon
	%Shadow.texture = _data['minigame'].icon

func _on_pressed() -> void:
	selected.emit(_data)


func _on_focus_entered() -> void:
	%Icon.scale = Vector2(0.5,0.5)
	%Shadow.scale = Vector2(0.5,0.5)
	%Icon.position.y = 35
	%Shadow.position.y = 42

func _on_focus_exited() -> void:
	%Icon.scale = Vector2(0.43,0.43)
	%Shadow.scale = Vector2(0.43,0.43)
	%Icon.position.y = 40
	%Shadow.position.y = 47
