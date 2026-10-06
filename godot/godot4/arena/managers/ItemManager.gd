extends Node

func _ready() -> void:
	%AutoSignals \
		.bind(%ArenaScope.item_obtained, _on_item_obtained)

func _on_item_obtained(item:Item, by_player:Player) -> void:
	# ignore player if item slot == general
	# store the item in session
	pass
