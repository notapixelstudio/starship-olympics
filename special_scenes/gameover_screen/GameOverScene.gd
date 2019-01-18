extends Node

onready var containerPlayer = $MarginContainer/HBoxContainer
onready var label = $MarginContainer/HBoxContainer/Label

signal rematch

func _ready():
	$VBoxContainer.get_child(0).grab_focus()

func initialize(winner:String, scores:Dictionary):
	label.text = scores[winner]["species"].to_upper() + " WON"
	print(scores)
	yield(get_tree().create_timer(2), "timeout")
	$VBoxContainer.get_child(0).grab_focus()
	# TODO: we should add the species altogether

func _on_Rematch_pressed():
	print("rematch")
	emit_signal("rematch")


func _on_Quit_pressed():
	get_tree().quit()
