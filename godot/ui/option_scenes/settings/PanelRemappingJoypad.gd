extends PanelRemapping

func _on_Device_value_changed(value):
	if value == null:
		return
	var joypads = Input.get_connected_joypads()
	var device_id = int(value.replace("joy", ""))
	if device_id > len(joypads):
		$Content/VBoxContainer/Preset.hide()
		$Content/VBoxContainer/HBoxContainer.hide()
		$Content/VBoxContainer/Default.hide()
		$Content/Label.show()
	else:
		$Content/VBoxContainer/Preset.show()
		$Content/VBoxContainer/HBoxContainer.show()
		$Content/VBoxContainer/Default.show()
		$Content/Label.hide()
