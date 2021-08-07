extends Node

var ball

func start():
	# a random players gets the ball at start
	ball = get_tree().get_nodes_in_group('Ball')[0]
	ball.linear_velocity = Vector2(10,0) if randf() > 0.5 else Vector2(-10,0)
	ball.impulse = 10
	ball.start()
	
	ball.connect('body_entered', self, '_on_ball_body_entered')
	
func _on_ball_body_entered(body):
	return
	if body is WallGoal and ball.owner_ship:
		var player = ball.owner_ship.get_player()
		if player != null and player.team != body.get_player().team:
			body.do_goal(player, ball.position)
