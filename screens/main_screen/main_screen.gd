extends "res://screens/basic_screen.gd"

func _ready():
	$VBoxContainer.add_constant_override("separation", 6)
	$VBoxContainer/StartCPU.grab_focus()
	global.chosen_species['p1'] = $P1.species.to_lower()
	global.chosen_species['p2'] = $P2.species.to_lower()
	print(global.chosen_species)
	"""
	if !bgm_creation.is_playing():
		bgm_creation.play()
	
	"""

func _on_Start_pressed():
	global.enemy = "CPU"
	change_scene()

func _on_Credits_pressed():
	change_scene("res://screens/credit_screen/credit_screen.tscn")


func _on_StartCPU_pressed():
	global.enemy = "CPU"
	change_scene()


func _on_StartHuman_pressed():
	global.enemy = "Human"
	change_scene()
