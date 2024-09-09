extends Area2D

@export var active := false: get = get_active, set = set_active
var owner_ship : Ship

func _ready():
	owner_ship = get_parent() # WARNING

func set_active(v):
	active = v
	$Sprite2D.visible = active
	$CollisionPolygon2D.call_deferred('set_disabled', not active)
	
func get_active() -> bool:
	return active
	
func _on_Scythe_body_entered(body):
	if active and body != owner_ship:
		if body is Ship:
			body.die(owner_ship)
			
