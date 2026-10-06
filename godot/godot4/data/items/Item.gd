class_name Item extends Resource

@export var name: String
@export var id: StringName


@export var is_glass: bool = false
@export var category: StringName

@export_enum(&'match', &'run') var duration: String # FIXME would be StringName in Godot 4.8
