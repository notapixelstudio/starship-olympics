extends Orchestrator

func _ready():
	await super()
	
	# 2 walls
	
	await Events.score_threshold_passed
	
	# 3 walls
	$AnimationPlayer.play("phase_2")
	
	await Events.score_threshold_passed
	
	# 4 walls
	$AnimationPlayer.play("phase_3")
