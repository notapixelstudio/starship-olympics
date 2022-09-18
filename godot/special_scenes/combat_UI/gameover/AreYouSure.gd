extends Control

var sure_of := {"map": "Are you sure to go back to map?", 
"quit": "Are you sure to quit?", 
"deck": "Do you want to use the new Deck?"}
export var where_to: PackedScene

var choice := false

signal choice_selected

func _ready():
	$YES.grab_focus()
	
func setup(key):
	$Label2.text = tr(sure_of[key])
	
func _on_NO_pressed():
	choice = false
	emit_signal("choice_selected")


func _on_YES_pressed():
	choice = true
	emit_signal("choice_selected")
