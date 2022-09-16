extends Area2D

@export (String, 'shield', 'plate', 'skin') var type = 'plate'

func _ready():
	$Polygon2D.polygon = $CollisionPolygon2D.polygon
	$Shadow.polygon = $CollisionPolygon2D.polygon
	up(type)

func up(new_type):
	type = new_type
	match type:
		'shield':
			$Polygon2D.modulate = Color('#008bff')
		'plate':
			$Polygon2D.modulate = Color.WHITE
		'skin':
			$Polygon2D.modulate = Color.GREEN
	enable_collisions()
	$AnimationPlayer.play("reset")

func down():
	# collisions will be disabled near the end of the animation
	$AnimationPlayer.stop() # this would make the sector flash again
	if type == 'plate':
		$AnimationPlayer.play("IndestructibleHit")
	else:
		$AnimationPlayer.play("Disappear")
	
func enable_collisions():
	$CollisionPolygon2D.call_deferred('set_disabled', false)
	
func disable_collisions():
	$CollisionPolygon2D.call_deferred('set_disabled', true)
	if type == 'skin':
		await get_tree().create_timer(5).timeout
		if type == 'skin': # shield type could have changed (e.g., if switched unchecked)
			up('skin')

func _on_ShieldWall_body_entered(body):
	if body is Bomb or body is Bullet:
		body.dissolve()
		body.queue_free()
		
		self.down()
