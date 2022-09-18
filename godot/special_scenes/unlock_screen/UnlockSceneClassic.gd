extends CanvasLayer

signal unlocking_animation_over

func _ready():
	$"%ColorRect".visible = false

func unlock(what: PackedScene, stay_in_screen:= false):
	$"%ColorRect".visible = true
	self.visible = true
	var unlock_thing= what.instance()
	$"%Content".add_child(unlock_thing)
	yield(get_tree().create_timer(2), "timeout")
	if stay_in_screen:
		# tween to put it somewhere in the screen
		unlock_thing.scale = Vector2(0.2,0.2)
		unlock_thing.position = $Position2D.position
		
	else:
		# animate and queue free
		unlock_thing.queue_free()
	emit_signal("unlocking_animation_over")
	$"%ColorRect".visible = false
	
func reset():
	$"%ColorRect".visible = false
	self.visible = false
	for unlock_thing in $"%Content".get_children():
		(unlock_thing as Node).queue_free()
