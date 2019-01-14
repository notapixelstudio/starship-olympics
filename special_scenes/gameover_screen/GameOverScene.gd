extends Node

onready var containerPlayer = $MarginContainer/HBoxContainer
onready var label = $MarginContainer/HBoxContainer/Label

func _ready():
	pass

func initialize(winner:String, scores:Dictionary):
	label.text = winner + " WON"
	print(scores)
	# TODO: we should add the species altogether
	