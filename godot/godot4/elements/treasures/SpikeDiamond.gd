extends Treasure


func hurt(sth):
	if sth.has_method('suffer_damage'):
		sth.suffer_damage(1)
		shine()
		
		%AnimationPlayer.stop()
		%AnimationPlayer.play('KillFeedback')
