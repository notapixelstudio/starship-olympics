extends Node

export var HeartScene: PackedScene
export var y := 1800.0
export var width := 4000.0

func start():
	$AnimationPlayer.play("Spawn")

func spawn_alien():
	var alien = HeartScene.instance()
	alien.position = Vector2(width*(randf()-0.5), y)
	global.arena.battlefield.add_child(alien)
	alien.start()
