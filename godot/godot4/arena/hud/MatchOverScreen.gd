extends ColorRect

var session_scores = {}

func hide() -> void:
	modulate = Color(0,0,0,0)

func show() -> void:
	%AnimationPlayer.play("appear")
	
func _on_appear() -> void:
	%Leaderboard.reorder()

func set_players(players:Array) -> void:
	if not is_inside_tree():
		await self.ready
	%Leaderboard.players = players

func set_session_scores(session_scores:Dictionary) -> void:
	if not is_inside_tree():
		await self.ready
	%Leaderboard.session_scores = session_scores

func set_match_winners(match_winners:Array[String]) -> void:
	if not is_inside_tree():
		await self.ready
	%Leaderboard.match_winners = match_winners
