tool
extends Node2D

export var ground_radius := 200 setget set_ground_radius
export var atmosphere_radius := 600 setget set_atmosphere_radius

func set_ground_radius(v):
	ground_radius = v
	$Ground/GCircle.set_radius(v)
	$Soil.polygon = $Ground/GCircle.to_PoolVector2Array()

	
func set_atmosphere_radius(v):
	atmosphere_radius = v
	$Atmosphere/GCircle.set_radius(v)
	$Air.polygon = $Atmosphere/GCircle.to_PoolVector2Array()
