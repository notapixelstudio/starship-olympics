extends Node2D

export var hook_to : NodePath setget set_hook_to

func set_hook_to(v):
	hook_to = v
	$LastPinJoint.node_b = hook_to
	
