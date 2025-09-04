@tool
extends Area2D
class_name ShieldWall

@export_enum('shield', 'plate', 'skin') var type = 'skin'
@export var starting_health := 3
@export var starts_disabled := true
@export var respawn_time := 6
@export var symbol_scale := 1.0: set = set_symbol_scale
@export var show_edges := true : set = set_show_edges

var polygon : PackedVector2Array
var health = starting_health

func set_symbol_scale(v: float) -> void:
	symbol_scale = v
	if not is_inside_tree():
		await self.ready
	$Sprite2D.scale = Vector2(symbol_scale, symbol_scale)
	
func set_show_edges(v: bool) -> void:
	show_edges = v
	%IsoPolygon.set_show_edges(show_edges)
	
func start():
	if starts_disabled:
		disable_collisions()
	else:
		up(type)
	
func set_polygon(v: PackedVector2Array) -> void:
	polygon = v
	%CollisionPolygon2D.set_polygon(polygon)
	%IsoPolygon.set_polygon(polygon)

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
	
#	$Polygon2D.modulate = Color('#808bee')
#	$Sprite.modulate = Color('#808bee')
#	$Line2D.modulate = Color('#909bff')
#	$IsoPolygon.color = Color('#a0abee')
	#$Polygon2D.modulate = Color('#207bff')
	#$Sprite2D.modulate = Color('#70abff')
	#$Line2D.modulate = Color('#3cd7ff')
	#$IsoPolygon.color = Color('#306bff')
	
	enable_collisions()
	$AnimationPlayer.play("reset")

func down():
	if health <= 0 or $AnimationPlayer.is_playing(): # no damage if just taken damage
		return
		
	health -= 1
	
	SoundEffects.play($DamageSFX)
	if health <= 0:
		# collisions will be disabled near the end of the animation
		$AnimationPlayer.play("Disappear")
	else:
		$AnimationPlayer.play("Hit")
	
func enable_collisions():
	$CollisionPolygon2D.call_deferred('set_disabled', false)
	
func disable_collisions():
	$CollisionPolygon2D.call_deferred('set_disabled', true)
	if type == 'skin':
		await get_tree().create_timer(respawn_time).timeout
		if type == 'skin': # shield type could have changed (e.g., if switched off)
			up('skin')

func _on_body_entered(body: Node2D) -> void:
	Events.collision.emit(self, body)
