extends Node

onready var containerPlayer = $MarginContainer/HBoxContainer
onready var label = $MarginContainer/HBoxContainer/Label
onready var container = $MarginContainer/HBoxContainer

signal rematch

func _ready():
	$VBoxContainer.get_child(0).grab_focus()

func initialize(winner:String, scores:Dictionary):
	var uid_winner = scores[winner]["id"]
	label.text = scores[winner]["species"].to_upper() + " WON"
	var template = scores[winner]["species_template"]
	container.get_node("winner").set_species(template.character_ok)
	var loser_ref = container.get_node("winner")
	for player in scores:
		if player == winner:
			continue
		
		var loser = loser_ref.duplicate()
		template = scores[player]["species_template"]
		container.add_child(loser)
		loser.set_species(template.character_beaten)
		
	print(scores)
	yield(get_tree().create_timer(2), "timeout")
	$VBoxContainer.get_child(0).grab_focus()
	# TODO: we should add the species altogether

func _on_Rematch_pressed():
	print("rematch")
	emit_signal("rematch")


func _on_Quit_pressed():
	get_tree().quit()
