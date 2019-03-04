tool
extends Node2D

export var anim : PackedScene 

func _ready():
	initialize(anim)
	
func initialize(new_anim : PackedScene):
	anim = new_anim
	add_child(anim.instance())
