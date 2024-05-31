extends Node2D


func _ready() -> void:
	Events.score_updated.connect(_on_score_updated)
	
func _on_score_updated(new_score:float, team:String):
	get_node(team).set_text(str(new_score))
