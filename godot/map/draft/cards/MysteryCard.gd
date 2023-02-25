extends DraftCard
class_name MysteryCard

export var name : String
export var description : String
export var mystery_cover : Texture
export var subcards : Array = [] # Array of DraftCard
export (String, 'mystery', "blue", "white", "cyan", "red", "yellow", 'green', "magenta") var color = 'mystery'

var _subcards_copy : Array = []
var current_subcard : DraftCard = null


func randomize_minigame() -> void:
	randomize()
	if len(_subcards_copy) <= 0:
		_subcards_copy = subcards.duplicate()
		_subcards_copy.shuffle()
		
		# prefer subcards not already seen, if possible
		_subcards_copy.sort_custom(self, "sort_new_subcards_first")
		
	current_subcard = _subcards_copy.pop_front()

func sort_new_subcards_first(a, b):
	return not (global.the_game.get_deck().get_remembered_card_ids().has(a.get_id()))

func on_card_drawn() -> void:
	randomize_minigame()
	
func get_minigame() -> Minigame:
	return current_subcard.get_minigame() if current_subcard else null
	
func get_cover() -> Texture:
	return mystery_cover

func has_level_for_player_count(player_count: int) -> bool:
	# a mystery card is good for this player count iff all its subcards are good for this player count
	for subcard in subcards:
		if not subcard.has_level_for_player_count(player_count):
			return false
	return true
	
# this has to call MysteryCard.has_level_for_player_count()
func get_available_player_counts(possible_players: Array) -> Array:
	var player_counts := []
	for player_count in possible_players:
		if self.has_level_for_player_count(player_count):
			player_counts.append(player_count)
	return player_counts
	
func get_name() -> String:
	return name
	
func get_description() -> String:
	return description
	
func get_icon() -> Texture:
	return get_cover()

func get_color() -> Array:
	return color
