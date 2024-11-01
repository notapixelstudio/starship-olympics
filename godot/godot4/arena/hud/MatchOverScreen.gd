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

func set_session(v:Session) -> void:
	session = v

func _ready() -> void:
	%Leaderboard.players = players
	%Leaderboard.session = session
	%Leaderboard.redraw()
