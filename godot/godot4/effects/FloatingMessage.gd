extends Node2D

@export var still : bool = false

func _ready():
	if not still:
		appear()

func set_message(value):
	var msg
	if typeof(value) == TYPE_INT or typeof(value) == TYPE_FLOAT:
		var sgn = ""
		if value >= 0:
			sgn = "+"
		else:
			$Label.add_theme_color_override('font_outline_color', Color.RED)
		if typeof(value) == TYPE_FLOAT:
			msg = sgn + str("%0.2f" % value)
		else:
			msg = sgn + str(value)
	else:
		msg = value
		
	$Label.text = tr(msg)
	
func set_color(color : Color):
	$Label.add_theme_color_override('font_color', color)
	
signal end
func _on_AnimationPlayer_animation_finished(anim_name):
	if not still:
		queue_free()
	else:
		$AnimationPlayer.stop(true)
	emit_signal('end')
	
func appear():
	$AnimationPlayer.play("Appear")
	
	
