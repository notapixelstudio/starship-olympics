extends Control

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
onready var first_choice = get_node("container/Local Multiplayer")

func _ready():
	first_choice.grab_focus()



func _on_Single_Player_pressed():
	global.enemy = "CPU"
	get_tree().change_scene("res://screens/character_selection_screen/CharacterSelection.tscn")


func _on_Local_Multiplayer_pressed():
	global.enemy = "Human"
	get_tree().change_scene("res://screens/character_selection_screen/CharacterSelection.tscn")
