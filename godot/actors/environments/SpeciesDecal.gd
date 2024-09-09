@tool
extends Node2D

@export var goal_owner : NodePath

func _ready():
	await get_tree().idle_frame
	
	var player = get_node(goal_owner).get_player()
	$"%Label".text = player.get_username().to_upper()
	$"%Label".modulate = player.get_color()
	
