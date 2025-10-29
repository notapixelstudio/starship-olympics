extends Node

func _ready():
	Events.match_over.connect(_on_match_over)
	Events.blocks_cleared.connect(_on_blocks_cleared)

func _on_blocks_cleared(field:BlocksField, amount:int, global_position:Vector2):
	assert(traits.has_trait(field, 'Ownership'), 'No ownership trait found for BlocksField: ' + str(field))
	var players = traits.get_trait(field, 'Ownership').get_players()
	
	# assign points
	Events.points_scored.emit(amount, players[0].get_team()) # FIXME just one player for team!
	# show feedback
	Events.message.emit(amount, players[0].get_color(), global_position)
	
func _on_match_over(data:Dictionary) -> void:
	if Events.blocks_cleared.is_connected(_on_blocks_cleared):
		Events.blocks_cleared.disconnect(_on_blocks_cleared)
