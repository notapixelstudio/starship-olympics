extends Node

func _ready() -> void:
	Events.score.connect(_on_score)
	
func _on_score(amount, author:Ship, global_position:Vector2) -> void:
	# assign points
	Events.points_scored.emit(float(amount), author.get_team())
	if global_position != null:
		# show feedback where the ship is
		Events.message.emit(amount, author.get_color(), author.global_position)
