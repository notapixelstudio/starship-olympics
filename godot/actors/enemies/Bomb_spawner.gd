extends Node2D

const Bomb = preload("res://actors/weapons/Bomb.tscn")

var arena

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	$Dashed_container.visible = false
	arena = get_parent().get_parent() # WARNING traversing the tree is error prone

func spawn():
	$Dashed_container.visible = false
	var bomb = arena.spawn_bomb(position, null, null)
	bomb.connect("detonate", self, "ready_to_respawn",[], CONNECT_ONESHOT)
	
func ready_to_respawn():
	$Dashed_container.visible = true
	yield(get_tree().create_timer(5.0), "timeout")
	spawn()