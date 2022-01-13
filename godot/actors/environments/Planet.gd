tool
extends Node2D

export var ground_radius := 200 setget set_ground_radius
export var atmosphere_radius := 600 setget set_atmosphere_radius
const NEAR_AREA_ALTITUDE := 20.0

func set_ground_radius(v):
	ground_radius = v
	$Ground/GCircle.set_radius(v)
	var near_circle = GCircle.new()
	near_circle.set_radius(ground_radius+NEAR_AREA_ALTITUDE)
	$NearArea/CollisionPolygon2D.polygon = near_circle.to_PoolVector2Array()
	
func set_atmosphere_radius(v):
	atmosphere_radius = v
	$Atmosphere/GCircle.set_radius(v)
	$Air.polygon = $Atmosphere/GCircle.to_PoolVector2Array()
	$FarArea/CollisionPolygon2D.polygon = $Atmosphere/GCircle.to_PoolVector2Array()

func _on_NearArea_body_entered(body):
	Events.emit_signal("planet_reached", self, body)
