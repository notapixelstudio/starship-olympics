extends Pentagoal

func _ready():
	$AnimationPlayer2.playback_speed = 1 + randf()
	
func _on_goal_done(player, goal, pos):
	if current_ring < 0:
		$"%Star".visible = false
