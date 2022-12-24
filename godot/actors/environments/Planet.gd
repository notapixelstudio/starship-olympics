tool
extends Node2D

export var ground_radius := 200.0 setget set_ground_radius
export var atmosphere_radius := 600.0 setget set_atmosphere_radius
const NEAR_AREA_ALTITUDE := 20.0

func set_ground_radius(v):
	ground_radius = v
	
	var gcircle = GCircle.new()
	gcircle.precision = 30
	gcircle.set_radius(ground_radius)
	$Sprite.scale = Vector2(ground_radius/200.0, ground_radius/200.0)
	$Shadow.scale = Vector2(ground_radius/200.0, ground_radius/200.0)
	$Solid/CollisionPolygon2D.polygon = gcircle.to_PoolVector2Array()
	
	var near_circle = GCircle.new()
	near_circle.set_radius(ground_radius+NEAR_AREA_ALTITUDE)
	$NearArea/CollisionPolygon2D.polygon = near_circle.to_PoolVector2Array()
	
func set_atmosphere_radius(v):
	atmosphere_radius = v
	var gcircle = GCircle.new()
	gcircle.precision = 30
	gcircle.set_radius(v)
	$Air.polygon = gcircle.to_PoolVector2Array()
	$FarArea/CollisionPolygon2D.polygon = gcircle.to_PoolVector2Array()
	$Clouds.scale = Vector2(atmosphere_radius/600.0*2.15, atmosphere_radius/600.0*2.15)
	$AirLine.points = gcircle.to_closed_PoolVector2Array()
	
	# random clouds
	randomize()
	$Clouds.self_modulate = Color(1,1,1,0.08) if randf() > 0.33 else Color(1,1,1,0.04)
	$Clouds.flip_h = randf() > 0.5
	$Clouds.flip_v = randf() > 0.5

func _on_NearArea_body_entered(body):
	Events.emit_signal("planet_reached", self, body)
