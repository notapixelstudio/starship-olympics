tool

extends Area2D

class_name Cell

func _ready():
	refresh()
	
func _on_GShape_changed():
	refresh()
	
func refresh():
	var gshape = get_gshape()
	
	if not gshape:
		return
		
	if not gshape.is_connected('changed', self, '_on_GShape_changed'):
		gshape.connect('changed', self, '_on_GShape_changed')
		
	#$Polygon2D.polygon = gshape.to_PoolVector2Array()
	#$Line2D.points = gshape.to_closed_PoolVector2Array()
	$CollisionShape2D.set_shape(gshape.to_Shape2D())
	
	#$Polygon2D.color = Color(0,0,0,0)
	#$Line2D.default_color = Color(0.2,0.7,1,0.3)
	
func get_gshape():
	for child in get_children():
		if child is GShape:
			return child
	return null
	
func _on_Conquerable_changed():
	var ship = $Entity/Conquerable.get_species()
	
	if ship != null:
		#$Polygon2D.color = Color(1,1,1,0.4)
		#$Line2D.default_color = Color(1,1,1,0.1)
		$SpriteFilled.modulate = $Entity/Conquerable.get_species().species.color
		$SpriteFilled.visible = true
		$AnimationPlayer.queue('Appear')
	else:
		$AnimationPlayer.queue('Disappear')
		
func flash():
	if $AnimationPlayer.current_animation != 'Flash' and len($AnimationPlayer.get_queue()) <= 1:
		$AnimationPlayer.queue('Flash')
	
