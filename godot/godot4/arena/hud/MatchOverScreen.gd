extends ColorRect

var session_scores = {}

func _ready() -> void:
	Events.match_over.connect(_on_match_over)
	Events.match_over_anim_ended.connect(_on_match_over_anim_ended)
	
	
func _on_match_over(data: Dictionary) -> void:
	print(data)
	
	
	pass#%Winner.text = 'WINNERS: ' + ' '.join(data['winners'])
	
func _on_match_over_anim_ended() -> void:
	visible = true
	%AnimationPlayer.play("appear")

func set_players(players: Array) -> void:
	if not is_inside_tree():
		await self.ready
	%Leaderboard.players = players
