extends Orchestrator

func _ready():
	await super()
	$AnimationPlayer.play("phase_1")
	await Events.score_threshold_passed
	$AnimationPlayer.play("phase_2")
	await Events.score_threshold_passed
	$AnimationPlayer.play("phase_3")
