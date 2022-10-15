extends Area2D
class_name Rototile

var rotations := 0
var angle := 0.0

signal start_rotating
signal rotation_finished
signal all_rotations_finished

func show_tap_preview(ship):
	$Polygon2D.modulate = Color.white
	
func hide_tap_preview():
	$Polygon2D.modulate = Color('#b3b3b3')
	
func tap(author):
	rotations += 1
	if rotations == 1:
		# start rotating
		emit_signal('start_rotating')
		do_rotation()
	
func do_rotation():
	var tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	angle += PI/2
	tween.tween_property(self, 'rotation', angle, 0.5)
	tween.connect('finished', self, '_on_rotation_finished')

func _on_Rototile_body_entered(body):
	if body is Ship:
		Events.emit_signal("tappable_entered", self, body)
		
func _on_ExitArea_body_exited(body):
	if body is Ship:
		Events.emit_signal("tappable_exited", self, body)
		
func _on_rotation_finished():
	emit_signal('rotation_finished')
	rotations -= 1
	if rotations > 0:
		do_rotation()
	else:
		emit_signal('all_rotations_finished')
