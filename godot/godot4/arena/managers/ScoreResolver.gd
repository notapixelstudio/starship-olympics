extends Node

func _ready() -> void:
	Events.score.connect(_on_score)
	
func _on_score(amount, player:Player, global_position:Vector2) -> void:
	# assign points
	Events.points_scored.emit(float(amount), player.get_team())
	Events.message.emit(amount, player.get_color(), global_position)
