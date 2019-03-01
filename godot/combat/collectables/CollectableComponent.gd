extends Node

var collected : bool

func _ready():
	collected = false
	
func collect():
	collected = true
	
func lose():
	collected = false
	
func is_collectable():
	return collected == false
	