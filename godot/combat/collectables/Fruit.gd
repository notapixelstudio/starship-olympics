@tool
extends RigidBody2D

class_name Fruit

@export (String, 'pear', 'banana', 'grape', 'cherry') var type :
	get:
		return type # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_type
@export var random = false

func set_type(v):
	type = v
	refresh()
	
func _ready():
	refresh()
	
func refresh():
	if random:
		type = ['pear', 'banana', 'grape', 'cherry'][randi()%4]
	if not is_inside_tree():
		await self.ready
	$Sprite2D.texture = load('res://assets/sprites/fruits/'+type+'.png')
	
signal collected

func collect(by):
	# queue_free() # FIXME? these are managed by spawners... mmm
	emit_signal('collected', by)
