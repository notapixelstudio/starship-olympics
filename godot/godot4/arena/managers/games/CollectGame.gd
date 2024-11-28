extends Node


func _ready():
	Events.match_over.connect(_on_match_over)
	Events.sth_collected.connect(_on_sth_collected)
	
func _on_sth_collected(collector, collectee):
	if not collector is Ship:
		return
		
	# assign points
	Events.points_scored.emit(float(collectee.get_points()), collector.get_team())
	# show feedback
	Events.message.emit(collectee.get_points(), collector.get_color(), collectee.global_position)
	
func _on_match_over(data:Dictionary) -> void:
	if Events.sth_collected.is_connected(_on_sth_collected):
		Events.sth_collected.disconnect(_on_sth_collected)
