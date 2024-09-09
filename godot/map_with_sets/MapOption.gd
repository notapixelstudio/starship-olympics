extends MapLocation

class_name MapOption

@export var value_name : String = "win"
@export var selection : Array = []
@export var global_option : bool = true
@export var node_owner_path : NodePath
@export var single_texture: Texture2D
var index : int = 0
var node_owner

@export var description = "set the number of victories"
@onready var sprite = $Sprite2D

func _ready():
	while not node_owner:
		node_owner = global if global_option else get_node(node_owner_path)
	if selection:
		initialize()
		
	# start the looping animation with a random value
	$AnimationPlayer.advance(randf()*4)
	$Label.text = self.name

func initialize( starting_from: int = 0, options: int = 0):
	var new_selection = []
	for i in range(starting_from, options):
		new_selection.append(i)
	
	if new_selection:
		selection = new_selection
	
	var value = node_owner.get(value_name)
	index = selection.find(value) if selection.find(value)>=0 else 0
	node_owner.set(value_name, selection[index])
	if single_texture:
		sprite.texture = single_texture
	else:
		sprite.texture = sprite.get_child(index).texture
	# label.text = description.format({"_": selection[index]})
	
func tap(author: Ship):
	index = (index + 1) % len(selection)
	
	#get_child(index).visible = true
	node_owner.set(value_name, selection[index])
	if not single_texture:
		sprite.texture = sprite.get_child(index).texture
	# label.text = description.format({"_": selection[index]})
	$act.play()
	
func show_tap_preview(_author):
	$Label.visible = true
	
func hide_tap_preview():
	$Label.visible = false
