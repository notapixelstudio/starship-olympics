extends Area2D

@export var active := false :
	get:
		return active # TODOConverter40 Copy here content of get_active
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_active
var owner_ship : Ship

func _ready():
	owner_ship = get_parent() # WARNING
	owner_ship.connect('overcharging_started',Callable(self,'_on_overcharging_started'))
	owner_ship.connect('charging_ended',Callable(self,'_on_charging_ended'))

func set_active(v):
	active = v
	$Sprite2D.visible = active
	$CollisionPolygon2D.call_deferred('set_disabled', not active)
	
func get_active() -> bool:
	return active
	
func _on_Drill_body_entered(body):
	if active and body != owner_ship:
		if body is Ship:
			body.die(owner_ship)
	
func _on_overcharging_started():
	if active:
		ignite_drill()
		
func _on_charging_ended():
	$Timer.start()
	
func _on_Timer_timeout():
	cool_drill()
	
func ignite_drill():
	$Aura.visible = true
	$AuraCollision.disabled = false
	
func cool_drill():
	$Aura.visible = false
	$AuraCollision.disabled = true
	
