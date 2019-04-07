extends ModeManager

const LAP_SCORE = 10
var angles : Array = [0,0]

signal score
func _process(delta):
	if not enabled:
		return
		
	var i = 0
	for racer in get_tree().get_nodes_in_group('players'):
		var partial_score = 0
		var angle = PI+racer.position.angle()
		
		if angle-angles[i] < -1.9*PI:
			partial_score += LAP_SCORE
		if angle-angles[i] > 1.9*PI:
			partial_score -= LAP_SCORE
			
		partial_score += (angle-angles[i])/2/PI*LAP_SCORE
		emit_signal('score', racer.species, partial_score)
		
		angles[i] = angle
		i += 1
		
# WARNING racing backwards has an unintended effect:
# you start scoring points as soon as you move forward, not as
# you cross the starting line
