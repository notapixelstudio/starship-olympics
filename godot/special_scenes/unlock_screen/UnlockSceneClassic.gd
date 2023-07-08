extends CanvasLayer

signal unlocking_animation_over

func _ready():
	$"%ColorRect".visible = false

func unlock(what: PackedScene, stay_in_screen:= false, method_name := "first_unlock"):
	$"%ColorRect".visible = true
	self.visible = true
	var unlock_thing= what.instantiate()
	$"%Content".add_child(unlock_thing)
	unlock_thing.call(method_name)
	await unlock_thing.animation_over
	if stay_in_screen:
		var tween := create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN_OUT)
		tween.parallel().tween_property(unlock_thing, 'scale', Vector2(0.2,0.2), 1.0)
		tween.parallel().tween_property(unlock_thing, 'position', $Marker2D.position, 1.0)
		# tween to put it somewhere in the screen
		await tween.finished
		
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
