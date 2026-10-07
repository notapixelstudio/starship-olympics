class_name Item extends Resource
## Items are data: what they do is written in the arena ItemManager, keyed by [member id],
## so effects can look at the whole inventory and combine.
##

@export var id: StringName
@export var name: String
@export_multiline var description: String = ""

@export_enum(&'general', &'player', &'ship', &'hat', &'ball', &'weapon', &'weapon-back') var slot: String 
@export_enum(&'match', &'run') var duration: String = "run" 


func is_general() -> bool:
	return slot == "general"


func lasts_one_match() -> bool:
	return duration == "match"
