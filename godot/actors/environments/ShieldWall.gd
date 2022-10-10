extends Area2D

export (String, 'shield', 'plate', 'skin') var type = 'plate'

func _ready():
	$Polygon2D.polygon = $CollisionPolygon2D.polygon
	$IsoPolygon.set_polygon($CollisionPolygon2D.polygon)
	$Line2D.points = $CollisionPolygon2D.polygon + PoolVector2Array([$CollisionPolygon2D.polygon[0]])
	up(type)

func up(new_type):
	type = new_type
	match type:
		'shield':
			$Polygon2D.modulate = Color('#008bff')
			$Line2D.modulate = Color('#008bff')
			$IsoPolygon.color = Color('#008bff')
		'plate':
			$Polygon2D.modulate = Color('#edd7a9')
			$Line2D.modulate = Color('#edd7a9')
			$IsoPolygon.color = Color('#edd7a9')
		'skin':
			$Polygon2D.modulate = Color('#2fe257')
			$Line2D.modulate = Color('#2fe257')
			$IsoPolygon.color = Color('#2fe257')
	enable_collisions()
	$AnimationPlayer.play("reset")

func down():
	if $AnimationPlayer.is_playing():
		return
		
	# collisions will be disabled near the end of the animation
	#$AnimationPlayer.stop() # this would make the sector flash again
	if type == 'plate':
		$AnimationPlayer.play("IndestructibleHit")
	else:
		$AnimationPlayer.play("Disappear")
	
func enable_collisions():
	$CollisionPolygon2D.call_deferred('set_disabled', false)
	
func disable_collisions():
	$CollisionPolygon2D.call_deferred('set_disabled', true)
	if type == 'skin':
		yield(get_tree().create_timer(5), "timeout")
		if type == 'skin': # shield type could have changed (e.g., if switched off)
			up('skin')

func _on_ShieldWall_body_entered(body):
	if body.has_method('destroy'):
		body.destroy()
		self.down()

#func _process(delta):
#	$Polygon2D.texture_rotation_degrees = rotation_degrees
