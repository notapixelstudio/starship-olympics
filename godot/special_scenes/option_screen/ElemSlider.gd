extends Control

export (String) var bus_name = "Master"
onready var sfx_effect  = $AudioStreamPlayer
onready var label = $VBoxContainer/Volume

func _ready():
	label.text = tr(label.text + " " + bus_name)


func _on_HSlider_value_changed(value):
	sfx_effect.play()
	var db_volume = linear2db(value)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus_name), db_volume)


func _on_HSlider_focus_entered():
	add_stylebox_override("panel", load("res://interface/themes/grey/focus.tres"))


func _on_HSlider_focus_exited():
	add_stylebox_override("panel", load("res://interface/themes/grey/normal.tres"))
