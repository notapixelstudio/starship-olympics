extends Node

onready var containerPlayer = $MarginContainer/HBoxContainer
onready var label = $MarginContainer/HBoxContainer/Label
onready var container = $MarginContainer/HBoxContainer

signal rematch
signal back_to_menu


func initialize(winner:String, scores:Dictionary):
	# let's remove the losers node, if they exists
	for i in range (2, container.get_child_count()):
		container.get_child(i).queue_free()
		
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
		
	yield(get_tree().create_timer(2), "timeout")
	$VBoxContainer.get_child(0).grab_focus()
	# TODO: we should add the species altogether

func _on_Rematch_pressed():
	emit_signal("rematch")

func _on_Quit_pressed():
	get_tree().quit()

func _on_Menu_pressed():
	# TODO: It will be whoever receive the signal to unpause
	get_tree().paused = false
	emit_signal("back_to_menu")
