extends Node2D

const scn_to_spawn = preload("res://actors/Bomb.tscn")

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	$Dashed_container.visible = false
	pass

func spawn():
	$Dashed_container.visible = false
	var new_obj = scn_to_spawn.instance()
	new_obj.velocity = Vector2()
	new_obj.position = position
	new_obj.connect("detonate", self, "ready_to_respawn",[], CONNECT_ONESHOT)
	get_parent().add_child(new_obj)


func ready_to_respawn():
	$Dashed_container.visible = true
	yield(get_tree().create_timer(5.0), "timeout")
	spawn()