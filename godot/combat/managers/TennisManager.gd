extends Node

var ball

export var sample_player_bricks_path : NodePath

func start():
	# a random players gets the ball at start
	ball = get_tree().get_nodes_in_group('Ball')[0]
	ball.linear_velocity = Vector2(10,0) if randf() > 0.5 else Vector2(-10,0)
	ball.impulse = 10
	ball.activate()
	
	ball.connect('body_entered', self, '_on_ball_body_entered')
	
func _on_ball_body_entered(body):
	if body is Brick:
		body.break(ball)
	return
	if body is WallGoal and ball.owner_ship:
		var player = ball.owner_ship.get_player()
		if player != null and player.team != body.get_player().team:
			body.do_goal(player, ball.position)

func _ready():
	var player_bricks = get_node(sample_player_bricks_path)
	var score := 0
	for brick in player_bricks.get_children():
		if not brick is Brick:
			continue
		score += 1
	
	global.arena.score_to_win_override = score
