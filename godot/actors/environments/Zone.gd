tool
extends Area2D

var active setget set_active, get_active
var player setget set_player, get_player

signal lost

func set_active(v):
	active = v
	
	$Background.visible = active
	$Border.self_modulate = Color(1,1,1) if active else Color(1,1,1,0.2)
	
	if active:
		add_to_group('in_camera')
	else:
		remove_from_group('in_camera')
		
func get_active():
	return active
	
func set_player(v):
	player = v
	
	if player != null:
		$Background.modulate = player.species.color
		$Border.modulate = player.species.color
		$Wrapper/Monogram.modulate = player.species.color
		$Wrapper/Monogram.text = player.species.get_monogram()
	else:
		$Background.modulate = Color(1,1,1)
		$Border.modulate = Color(1,1,1)
		$Wrapper/Monogram.modulate = Color(1,1,1)
		$Wrapper/Monogram.text = ''
		
func get_player():
	return player

func _ready():
	refresh_polygon()
	$GShape.connect('changed', self, 'refresh_polygon')
	
func refresh_polygon():
	var polygon = $GShape.to_PoolVector2Array()
	$CollisionPolygon2D.polygon = polygon
	$Background.polygon = polygon
	$Border.points = $GShape.to_closed_PoolVector2Array()
	
func _on_Zone_body_entered(body):
	if active and body is Ship:
		set_player(body.get_player())
		
func _on_Zone_body_exited(body):
	if active and body is Ship and body.get_player() == player:
		set_player(null)
		set_active(false)
		emit_signal('lost', self)
