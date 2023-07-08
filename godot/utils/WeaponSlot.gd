extends Node2D

var owner_ship: Ship

@export var arsenal : Dictionary # of id -> Weapon Scenes

func _ready():
	owner_ship = get_parent() # WARNING
	
	wield('none')

func wield(id: String) -> void:
	if not arsenal.has(id):
		return
		
	self.is_empty()
	add_child(arsenal[id].instantiate())
	
func is_empty() -> void:
	for child in self.get_children():
		child.queue_free()
