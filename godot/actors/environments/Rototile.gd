extends Area2D

var angle = 0
var tween

func show_tap_preview(ship):
	$Polygon2D.modulate = Color.white
	
func hide_tap_preview():
	$Polygon2D.modulate = Color('#b3b3b3')
	
func tap(author):
	angle += PI/2
	var tween := create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, 'rotation', angle, 1.0)

func _on_Rototile_body_entered(body):
	if body is Ship:
		Events.emit_signal("tappable_entered", self, body)
		
func _on_ExitArea_body_exited(body):
	if body is Ship:
		Events.emit_signal("tappable_exited", self, body)
		
