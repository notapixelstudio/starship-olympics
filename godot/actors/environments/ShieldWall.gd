extends Area2D

export (String, 'shield', 'plate', 'skin') var type = 'plate'
export var starting_health := 3
export var respawn_time := 6
export var symbol_scale := 1.0 setget set_symbol_scale

var health = starting_health

func set_symbol_scale(v: float) -> void:
	symbol_scale = v
	if not is_inside_tree():
		yield(self, "ready")
	$Sprite.scale = Vector2(symbol_scale, symbol_scale)
	
func _ready():
	$Polygon2D.polygon = $CollisionPolygon2D.polygon
	$IsoPolygon.set_polygon($CollisionPolygon2D.polygon)
	$Line2D.points = $CollisionPolygon2D.polygon + PoolVector2Array([$CollisionPolygon2D.polygon[0]])
	up(type)

func up(new_type):
	health = starting_health
	type = new_type
#	match type:
#		'shield':
#			$Polygon2D.modulate = Color('#008bff')
#			$Sprite.modulate = Color('#008bff')
#			$Line2D.modulate = Color('#008bff')
#			$IsoPolygon.color = Color('#008bff')
#		'plate':
#			$Polygon2D.modulate = Color('#edd7a9')
#			$Sprite.modulate = Color('#edd7a9')
#			$Line2D.modulate = Color('#edd7a9')
#			$IsoPolygon.color = Color('#edd7a9')
#		'skin':
#			$Polygon2D.modulate = Color('#2fe257')
#			$Sprite.modulate = Color('#2fe257')
#			$Line2D.modulate = Color('#2fe257')
#			$IsoPolygon.color = Color('#2fe257')
	$Polygon2D.modulate = Color('#668bff')
	$Sprite.modulate = Color('#668bff')
	$Line2D.modulate = Color('#668bff')
	$IsoPolygon.color = Color('#668bff')
	
	enable_collisions()
	$AnimationPlayer.play("reset")

func down():
	if health <= 0:
		return
		
	health -= 1
	
	# collisions will be disabled near the end of the animation
	$AnimationPlayer.advance(10) # should be anough to end the current animation and make the sector flash again
	if health > 0 or type == 'plate':
		$AnimationPlayer.play("IndestructibleHit")
	else:
		$AnimationPlayer.play("Disappear")
	
func enable_collisions():
	$CollisionPolygon2D.call_deferred('set_disabled', false)
	
func disable_collisions():
	$CollisionPolygon2D.call_deferred('set_disabled', true)
	if type == 'skin':
		yield(get_tree().create_timer(respawn_time), "timeout")
		if type == 'skin': # shield type could have changed (e.g., if switched off)
			up('skin')

func _on_ShieldWall_body_entered(body):
	if body.has_method('destroy'):
		body.destroy()
		self.down()

func _process(delta):
	$Sprite.rotation = -global_rotation
