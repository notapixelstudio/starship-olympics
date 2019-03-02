tool
extends Node2D

export var skin_anim : PackedScene 

onready var skin = $Graphics

func _ready():
	initialize(skin_anim)
	
func initialize(anim : PackedScene):
	skin_anim = anim
	$Graphics.add_child(skin_anim.instance())
	