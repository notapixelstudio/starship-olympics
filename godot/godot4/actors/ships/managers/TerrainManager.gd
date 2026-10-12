extends Node

@export var thrust := {
	&'default': 6700, # 6500
	&'ice': 2200
}
@export var linear_damp := {
	&'default': 7.0,
	&'ice': 1.3
}
@export var charge_brake := {
	&'default': 0.0,
	&'ice': 0.02
}
@export var dash_multiplier := {
	&'default': 3.0, # was 2.7, then 2.6 decreased to lessen the chance of tunneling
	&'ice': 1.8
}
@export var max_dash := {
	&'default': 10000, # virtually unbounded, standard max value should be under 5000
	&'ice': 4000
}

signal terrain_changed(from:StringName, to:StringName)

var _current_terrain := &"none"

func get_host():
	return get_parent()
	
func _ready() -> void:
	await get_host().ready
	_switch_terrain(&"default")
	
func _switch_terrain(type) -> void:
	if _current_terrain == type:
		return
	
	var old_terrain = _current_terrain
	_current_terrain = type
	terrain_changed.emit(old_terrain, _current_terrain)
	Events.log.emit('Terrain switched to: %s' % _current_terrain)
	
	# apply new terrain's parameters
	get_host().thrust = thrust[_current_terrain]
	get_host().linear_damp = linear_damp[_current_terrain]
	get_host().charge_brake = charge_brake[_current_terrain]
	get_host().dash_multiplier = dash_multiplier[_current_terrain]
	get_host().max_dash = max_dash[_current_terrain]

func get_current_terrain() -> String:
	return _current_terrain
	
func process_overlappers(overlappers:Array) -> void:
	for overlapper in overlappers:
		if overlapper is Ice:
			_switch_terrain(&"ice")
			return
			
	_switch_terrain(&"default")
