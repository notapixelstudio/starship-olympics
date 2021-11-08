extends GenericOption

export (String) var bus_name = "Master"
onready var sfx_effect  = $AudioStreamPlayer
onready var value_node = $VBoxContainer/HSlider
onready var description_node = $VBoxContainer/Volume
onready var hslider =$VBoxContainer/HSlider

func _process(delta):
	description_node.text = tr("Volume" + " " + bus_name)

func _ready():
	description_node.text = tr(description_node.text + " " + bus_name)
	value = node_owner.get(element_path)
	value_node.value = value
	
func _on_HSlider_value_changed(new_value: int):
	self.value = new_value
	sfx_effect.play()
	var db_volume = linear2db(float(value)/100)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus_name), db_volume)
	
func _on_HSlider_focus_entered():
	add_stylebox_override("panel", load("res://interface/themes/grey/focus.tres"))
	
func _on_HSlider_focus_exited():
	add_stylebox_override("panel", load("res://interface/themes/grey/normal.tres"))


func _on_Music_focus_entered():
	hslider.grab_focus()


func _on_Music_focus_exited():
	hslider.grab_focus()
