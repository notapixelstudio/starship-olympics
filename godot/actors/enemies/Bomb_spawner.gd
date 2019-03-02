extends Node2D

const Bomb = preload("res://actors/weapons/Bomb.tscn")

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	$Dashed_container.visible = false
	pass

func spawn():
	$Dashed_container.visible = false
	var bomb = Bomb.instance()
	bomb.initialize(position, null, null)
	bomb.connect("detonate", self, "ready_to_respawn",[], CONNECT_ONESHOT)
	get_parent().add_child(bomb)


func ready_to_respawn():
	$Dashed_container.visible = true
	yield(get_tree().create_timer(5.0), "timeout")
	spawn()