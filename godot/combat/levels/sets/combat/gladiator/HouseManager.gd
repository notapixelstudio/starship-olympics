extends AnimationPlayer


func _on_PowerUp_collected(by, house):
	play('shut_'+house)
