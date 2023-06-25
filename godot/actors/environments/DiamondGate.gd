extends Gate

func _on_DiamondGate_crossed(by_what, gate, trigger):
	global.the_match.add_score(by_what.get_player().get_id(), 1)
	global.arena.show_msg(by_what.get_color(), 1, by_what.position)
	queue_free()

func _ready():
	set_width(400+randf()*randf()*400)
	$AnimationPlayer2.play("RotateCW" if randf() > 0.5 else "RotateCCW")
	$AnimationPlayer2.seek(12*randf(), true)
	$AnimationPlayer2.stop(false)
	$AnimationPlayer2.set_speed_scale(0.3+randf()*0.7)

func start():
	$AnimationPlayer2.play()
