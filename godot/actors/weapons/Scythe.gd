extends Area2D

export var active = false setget set_active
var owner_ship : Ship

func _ready():
	owner_ship = get_parent() # WARNING

func set_active(v):
	active = v
	$Sprite.visible = active
	$CollisionPolygon2D.call_deferred('set_disabled', not active)
	
func _on_Scythe_body_entered(body):
	if active and body != owner_ship:
		if body is Ship:
			body.die(owner_ship)
			
