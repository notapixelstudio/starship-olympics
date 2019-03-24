extends Control

export (String) var bus_name = "Master"
onready var sfx_effect  = $AudioStreamPlayer
onready var label = $VBoxContainer/Volume

func _ready():
	label.text = label.text + " " + bus_name


func _on_HSlider_value_changed(value):
	sfx_effect.play()
	var db_volume = linear2db(value)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus_name), db_volume)
