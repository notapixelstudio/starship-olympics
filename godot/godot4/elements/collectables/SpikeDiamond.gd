class_name SpikeDiamond extends Treasure

func kill_feedback():
	%AnimationPlayer.stop()
	%AnimationPlayer.play('KillFeedback')
