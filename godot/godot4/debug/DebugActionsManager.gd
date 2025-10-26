extends Node

## Always processing, regardless of pause

@export var arena : Node

func _ready():
	if not OS.is_debug_build():
		queue_free()

func _unhandled_key_input(event) -> void:
	if OS.is_debug_build():
		# cause the clock to expire for testing
		if event.is_action_pressed("debug_action"):
			Events.force_match_over.emit("Match ended by user debug action key")
			
		# reset the current level
		if event.is_action_pressed("debug_restart_scene"):
			# harder way to reset the level than reload_current_scene()
			#Engine.time_scale = 1 # doesn't work as expected
			get_tree().paused = false
			var this_scene = load(arena.scene_file_path)
			arena.get_parent().add_child(this_scene.instantiate())
			arena.queue_free()
