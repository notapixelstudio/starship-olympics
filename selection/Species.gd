extends Control

enum Controls {CPU, KB1, KB2, JOY1, JOY2, JOY3, JOY4}

export (Controls) var controls = KB1
export (String) var species = "ROBOLORDS"

# maybe global?
const ControlsMap = {
	CPU : "cpu",
    KB1 : "kb1",
    KB2 : "kb2",
    JOY1 : "joy1",
    Controls.JOY2 : "joy2",
    Controls.JOY3 : "joy3",
    Controls.JOY4 : "joy4"
}

signal selected
signal deselected
signal leave
signal ready_to_fight

var disabled = false
var selected = false
var joined = true

var index_selection

onready var enabler = $Enabler
onready var speciesSelection = $SpeciesSelection
func _ready():
	
	change_species(species)
	
	# if CPU or fixed choice
	if disabled:
		disable_choice()
	
	# rotate of the ship and flip it
	

func change_species(new_species):
	pass

func _input(event):
	var this_control = ControlsMap[controls]
	if selected :
		if event.is_action_pressed(this_control+"_fire"):
			emit_signal("ready_to_fight")
		elif event.is_action_pressed(this_control+"_action"):
			deselect()
	elif joined:
		if event.is_action_pressed(this_control+"_right") and not selected:
			_on_Next_pressed()
		if event.is_action_pressed(this_control+"_left") and not selected:
			_on_Previous_pressed()
		if event.is_action_pressed(this_control+"_fire") and not selected:
			selected()
		if event.is_action_pressed(this_control+"_action") and not selected:
			leave()

func leave():
	joined = false
	enabler.visible = true
	disable_choice()
	unset_commands()
	emit_signal("leave")

func selected():
	get_node("selected").play()
	disable_choice()
	selected = true
	# global.chosen_species[name.to_lower()] = species
	change_species(species)
	# global.available_species.remove(global.available_species.find(species))
	emit_signal("selected")

func deselect():
	get_node("deselected").play()
	enable_choice()
	selected = false
	# global.available_species.append(species)
	emit_signal("deselected")
	
func _on_Previous_pressed():
	speciesSelection.previous()


func _on_Next_pressed():
	speciesSelection.next()

func disable_choice():
	pass
	

func enable_choice():
	joined = true
	enabler.visible = false
	pass

func unset_commands():
	joined = false
	get_node("VBoxContainer/Controls").unset_commands(global.controls[name.to_lower()])
	controls = CPU
	global.controls[name.to_lower()]
	
func set_commands(button):
	get_node("joined").play()
	joined = true
	for control in ControlsMap:
		if ControlsMap[control] in button:
			controls = control
			# update globals
			global.controls[name.to_lower()] = ControlsMap[controls]
			get_node("VBoxContainer/Controls").set_commands(ControlsMap[control])
			enable_choice()

# utils
func mod(a,b):
	var ret = a%b
	if ret < 0: 
		return ret+b
	else:
		return ret
