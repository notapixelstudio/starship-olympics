extends DraftCard
class_name MysteryCard

export var mystery_cover : Texture
export var subcards : Array = []
var current_subcard : DraftCard = null

func randomize_minigame() -> void:
	randomize()
	subcards.shuffle()
	current_subcard = subcards[0]

func on_card_drawn() -> void:
	randomize_minigame()
	
func get_minigame() -> Minigame:
	return current_subcard.get_minigame()
	
func is_winter() -> bool:
	return current_subcard.is_winter()
	
func get_cover() -> Texture:
	return mystery_cover

func has_level_for_player_count(player_count: int) -> bool:
	# a mystery card is good for this player count iff all its subcards are good for this player count
	for subcard in subcards:
		if not subcard.has_level_for_player_count(player_count):
			return false
	return true
