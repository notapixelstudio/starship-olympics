extends ColorRect

@export var players : Array[Player] : set = set_players
@export var session : Session : set = set_session

func hide() -> void:
	modulate = Color(0,0,0,0)

func show() -> void:
	%AnimationPlayer.play("appear")
	
func _on_appear() -> void:
	%Leaderboard.reorder()

func set_players(v:Array[Player]) -> void:
	players = v
	_refresh()

func set_session(v:Session) -> void:
	session = v
	_refresh()

func _refresh() -> void:
	if not is_inside_tree():
		if not self.ready.is_connected(_refresh):
			self.ready.connect(_refresh)
		return
		
	%Leaderboard.players = players
	%Leaderboard.session = session
