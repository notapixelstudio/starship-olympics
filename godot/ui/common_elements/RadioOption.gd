@tool
extends MapLocation

class_name MapRadio

@export var value_name : String = "custom_win"
@export var value : Array # workaround for variant types
@export var texture : Texture2D: set = set_texture
@export var label = "victories"

var active := false: set = set_active

func _ready():
	assert(len(value) == 1)
	
	add_to_group('radio_'+value_name)
	
	$Wrapper/Label.text = label
	refresh()
	
func refresh() -> void:
	self.set_active(global.get(value_name) == value[0])
	
func tap(author: Ship):
	if not status == TheUnlocker.UNLOCKED:
		return
		
	global.set(value_name, value[0])
	$act.play()
	
	# refresh all radios linked to the same value
	for radio in get_tree().get_nodes_in_group('radio_'+value_name):
		radio.refresh()
	
func show_tap_preview(_author):
	$Wrapper/Label.visible = true
	
func hide_tap_preview():
	$Wrapper/Label.visible = false

func set_texture(v: Texture2D) -> void:
	texture = v
	$Sprite2D.texture = v

func set_active(v: bool) -> void:
	active = v
	if active:
		$Sprite2D.modulate = Color.WHITE
		$Frame.modulate = Color.WHITE
	else:
		$Sprite2D.modulate = Color(0.5,0.5,0.5,1)
		$Frame.modulate = Color('#24334a')
