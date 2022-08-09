extends Resource

class_name DraftCard

export var minigame: Resource # Minigame
export var unlocks : Array = [] # of DraftCard IDs

export var winter : bool = false
export var perfectionist : bool = false

var new := false
var strikes := 0

func get_id() -> String:
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
	
func has_level_for_player_count(player_count: int) -> bool:
	return minigame.has_level_for_player_count(player_count)
	
func get_available_player_counts() -> Array:
	return minigame.get_available_player_counts()
	
func get_name() -> String:
	return minigame.get_name()
	
func get_description() -> String:
	return minigame.get_description()
	
func get_icon() -> Texture:
	return minigame.get_icon()

func set_new(v: bool) -> void:
	new = v
	
func is_new() -> bool:
	return new
