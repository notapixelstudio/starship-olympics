@tool
extends MapLocation

class_name MapMoon

@export var value_name : String = "flood"
@export var values : Array
@export var texture : Texture2D: set = set_texture
@export var textures : Array: set = set_textures
@export var label = "flood moon"

var value_index = 0

func _ready():
	assert(len(values) == len(textures))
	
	$Wrapper/Label.text = label
	refresh()
	
func refresh() -> void:
	var value = global.get(value_name)
	value_index = values.find(value)
	if not is_inside_tree():
		await self.ready
	$StatusSprite.texture = textures[value_index]
	
func tap(author: Ship):
	if not status == TheUnlocker.UNLOCKED:
		return
		
	global.set(value_name, values[ (value_index+1) % len(values) ])
	self.refresh()
	$act.play()
	
func show_tap_preview(_author):
	$Wrapper/Label.visible = true
	
func hide_tap_preview():
	$Wrapper/Label.visible = false

func set_texture(v: Texture2D) -> void:
	texture = v
	if not is_inside_tree():
		await self.ready
	$Sprite2D.texture = v
	
func set_textures(v: Array) -> void:
	textures = v
	self.refresh()
