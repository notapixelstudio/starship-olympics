tool
extends Node2D

export var goal_owner : NodePath

func _ready():
	yield(get_tree(), 'idle_frame')
	
	var player = get_node(goal_owner).get_player()
	$Label.text = player.get_id().to_upper()
	$Label.modulate = player.get_color()
	
