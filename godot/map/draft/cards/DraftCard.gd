extends Resource

class_name DraftCard

@export var minigame: Minigame # Minigame
@export var unlocks : Array = [] # of DraftCard IDs
var _unlocks_copy : Array = []
@export var unlock_strength := 1

@export var winter : bool = false
@export var perfectionist : bool = false

@export var tint : Color

var id = null

var new := false
var strikes := 0

func is_available_for_random_extraction():
	return true

func _init():
	_refill_unlocks()
	
func _refill_unlocks() -> void:
	randomize()
	_unlocks_copy = unlocks.duplicate()
	_unlocks_copy.shuffle()

func get_id() -> String:
	if id != null:
		return id
	else:
		return self.resource_path.get_basename().get_file()

func get_minigame() -> Minigame:
	return (minigame as Minigame)

func take_strike():
	strikes += 1
	
func reset_strikes():
	if strikes > 0:
		print("strikes reset for " + self.get_id())
	strikes = 0
	
func has_enough_strikes() -> bool:
	return strikes >= 3
	
func is_winter() -> bool:
	return winter
	
func is_perfectionist() -> bool:
	return perfectionist

func on_card_drawn() -> void:
	pass
	
func on_card_picked() -> void:
	pass
	
func has_level_for_player_count(player_count: int) -> bool:
	return (get_minigame() as Minigame).get_arena_filepath(player_count) != ""

func get_available_player_counts(possible_players: Array) -> Array:
	var ret = []
	for num_players in possible_players:
		if (get_minigame() as Minigame).get_arena_filepath(num_players) != "":
			ret.append(num_players)
	return ret
	
func get_name() -> String:
	return get_minigame().get_name()
	
func get_description() -> String:
	return get_minigame().get_description()
	
func get_icon() -> Texture2D:
	return get_minigame().get_icon()

func set_new(v: bool) -> void:
	new = v
	
func is_new() -> bool:
	return new

func get_tint() -> Color:
	return tint
	
func get_suit_top() -> Array:
	return get_minigame().get_suit_top()

func get_suit_bottom() -> Array:
	return get_minigame().get_suit_bottom()

func has_unlocks() -> bool:
	return len(unlocks) > 0
	
func get_unlock() -> String:
	if len(_unlocks_copy) <= 0:
		# we need to cycle unlocks again because there's a chance they have been discarded as duplicates
		# WARNING this implies that sometimes it fails to produce a new minigame (could be good, to be less predictable)
		_refill_unlocks()
	var unlock = _unlocks_copy.pop_front()
	print(get_id() + ' proposes to unlock ' + unlock)
	return unlock

func get_unlock_strength() -> int:
	return unlock_strength

func get_logo() -> CompressedTexture2D:
	if get_minigame():
		return get_minigame().get_icon()
	return null

func duplicate(subresources: bool = false) -> Resource:
	var dup = super.duplicate(subresources)
	dup.id = get_id() # this is needed, since duplicates do not have a resource path
	return dup
