extends Node2D

export var points : int = 1 setget set_points
export var still : bool = false

func _ready():
	if not still:
		appear()

func set_points(value):
	points = value
	var sgn = ""
	if points >=0:
		sgn = "+"
	$Label.text = tr(sgn+str(points))

signal end
func _on_AnimationPlayer_animation_finished(anim_name):
	if not still:
		queue_free()
	else:
		$AnimationPlayer.stop(true)
	emit_signal('end')
	
func appear():
	$AnimationPlayer.play("Appear")
	
	
