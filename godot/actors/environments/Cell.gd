@tool

extends Area2D

class_name Cell

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
	
