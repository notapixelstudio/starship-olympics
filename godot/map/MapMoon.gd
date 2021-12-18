tool
extends MapLocation

class_name MapMoon

export var value_name : String = "flood"
export var values : Array
export var textures : Array setget set_textures # Array of Textures
export var description = "flood arenas"

var value_index = 0

func _ready():
	assert(len(values) == len(textures))
	
	$Wrapper/Label.text = self.name
	refresh()
	
func refresh() -> void:
	var value = global.get(value_name)
	value_index = values.find(value)
	if not is_inside_tree():
		yield(self, "ready")
	$Sprite.texture = textures[value_index]
	
func tap(author: Ship):
	global.set(value_name, values[ (value_index+1) % len(values) ])
	$act.play()
	self.refresh()
	
func show_tap_preview(_author):
	$Wrapper/Label.visible = true
	
func hide_tap_preview():
	$Wrapper/Label.visible = false

func set_textures(v: Array) -> void:
	textures = v
	self.refresh()
