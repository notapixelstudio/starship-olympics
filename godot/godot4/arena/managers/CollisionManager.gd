extends Node

func _ready() -> void:
	Events.ship_collision.connect(_on_ship_collision)
	Events.other_collision.connect(_on_other_collision)
	
func _on_ship_collision(ship:Ship, collider:CollisionObject2D, area:String) -> void:
	if collider is Pew and area == 'hurt':
		ship.suffer_damage(1, collider)
		collider.destroy()
	
func _on_other_collision(actor:CollisionObject2D, collider:CollisionObject2D) -> void:
	assert(not actor is Ship) # for collisions involving Ships, use the 'ship_collision' signal insetad
	print('!')
