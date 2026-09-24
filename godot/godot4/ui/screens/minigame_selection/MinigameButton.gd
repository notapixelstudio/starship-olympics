extends Button

signal selected(data)

var _data

func set_data(v) -> void:
	_data = v
	text = _data['minigame'].title.to_upper()
	icon = _data['minigame'].icon

func _on_pressed() -> void:
	selected.emit(_data)
