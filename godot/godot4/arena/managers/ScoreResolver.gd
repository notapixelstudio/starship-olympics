extends Node

func _ready() -> void:
	Events.score.connect(_on_score)
	
func _on_score(amount, author:Ship, global_position:Vector2) -> void:
	# assign points
	Events.points_scored.emit(float(amount), author.get_team())
	# show feedback where the ship is if position was not given
	var position = author.global_position if global_position == null else global_position
	Events.message.emit(amount, author.get_color(), position)
