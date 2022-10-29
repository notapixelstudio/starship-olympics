extends Control

var sure_of := {"cards": "Are you sure to go back to the cards?", 
"quit": "Are you sure to quit?", 
"deck": "Do you want to use the new Deck?",
"continue": "Do you want to Continue your last session?",
"quit_current_game":"All progress will be lost! Really quit?"}
export var where_to: PackedScene

var choice := false

signal choice_selected

func _ready():
	$NO.grab_focus()
	
func setup(key):
	$Label2.text = tr(sure_of[key])
	
func _on_NO_pressed():
	choice = false
	emit_signal("choice_selected")


func _on_YES_pressed():
	choice = true
	emit_signal("choice_selected")
