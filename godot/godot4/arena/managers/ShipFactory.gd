extends Node
class_name ShipFactory

var _current_minigame : Minigame

func _ready() -> void:
	# make this available in the global context
	Context.ship_factory = self
	
func set_minigame(v:Minigame) -> void:
	_current_minigame = v
	
func create(player:Player, enabled:bool) -> Ship:
	var ship := _current_minigame.ship_scene.instantiate()
	ship.set_player(player)
	
	var brain
	if player.is_cpu():
		brain = _current_minigame.cpu_brain_scene.instantiate()
	else:
		brain = _current_minigame.player_brain_scene.instantiate()
		brain.set_controls(player.get_controls())
	brain.set_enabled(enabled)
	ship.add_child(brain)
	
	if _current_minigame.starting_weapon_scene:
		var weapon = _current_minigame.starting_weapon_scene.instantiate()
		ship.add_child(weapon)
	
	return ship
