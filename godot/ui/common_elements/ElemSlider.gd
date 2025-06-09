extends GenericOption

@export var bus_name := "Master"
@onready var sfx_effect  = $AudioStreamPlayer
@onready var value_node = $VBoxContainer/HSlider
@onready var description_node = $VBoxContainer/Volume
@onready var hslider =$VBoxContainer/HSlider

func setup():
	description_node.text = tr(description_node.text + " " + bus_name)
	#value = node_owner.get(element_path)
	#value_node.value = value
	
func _on_HSlider_value_changed(new_value: int):
	self.value = new_value
	sfx_effect.play()
	var db_volume = linear_to_db(float(value)/100)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus_name), db_volume)
	
func _on_HSlider_focus_entered():
	add_theme_stylebox_override("panel", load("res://interface/themes/olympic/focus.tres"))
	description_node.set("theme_override_colors/font_color",Color(0,0,0))
	
func _on_HSlider_focus_exited():
	add_theme_stylebox_override("panel", load("res://interface/themes/olympic/normal.tres"))
	description_node.set("theme_override_colors/font_color", null)


func _on_Music_focus_entered():
	hslider.grab_focus()


func _on_Music_focus_exited():
	hslider.grab_focus()
