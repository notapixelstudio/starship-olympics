extends Sprite2D

@onready var RadioWave = preload('res://actors/weapons/RadioWave.tscn')

func start():
	$AnimationPlayer.play("Default")
	
func emit_wave():
	var w = RadioWave.instantiate()
	w.position = global_position
	get_parent().add_child(w)
	
