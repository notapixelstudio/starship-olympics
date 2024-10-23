extends ColorRect

var session_scores = {}

func hide() -> void:
	modulate = Color(0,0,0,0)

func show() -> void:
	%AnimationPlayer.play("appear")

func set_players(players:Array) -> void:
	if not is_inside_tree():
		await self.ready
	%Leaderboard.players = players

func set_session_scores(session_scores:Dictionary) -> void:
	if not is_inside_tree():
		await self.ready
	%Leaderboard.session_scores = session_scores
