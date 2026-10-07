class_name Item extends Resource
## Items are data: what they do is written in the arena ItemManager, keyed by [member id],
## so effects can look at the whole inventory and combine.
##

@export var id: StringName
@export var name: String
@export_multiline var description: String = ""

@export_enum(&'general', &'player', &'ship', &'hat', &'ball', &'weapon', &'weapon-back') var slot: String # FIXME would be StringName in Godot 4.8
@export_enum(&'match', &'run') var duration: String = "run" # FIXME would be StringName in Godot 4.8


func is_general() -> bool:
	return slot == "general"


func lasts_one_match() -> bool:
	return duration == "match"
