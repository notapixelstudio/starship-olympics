extends Resource
class_name VBeveledRect

@export var width := 200 : set = set_width
@export var height := 200 : set = set_height
@export var bevel := 50 : set = set_bevel

var _dirty := false
func update() -> void:
	if not _dirty:
		_dirty = true
		_notify_changed.call_deferred()

func _notify_changed() -> void:
	emit_changed()
	_dirty = false

func set_width(v: int) -> void:
	width = v
	update()
	
func set_height(v: int) -> void:
	height = v
	update()
	
func set_bevel(v: int) -> void:
	bevel = v
	update()
