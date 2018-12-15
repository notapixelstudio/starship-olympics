extends Control

enum Controls {CPU, KB1, KB2, JOY1, JOY2, JOY3, JOY4, NO}
# maybe global?
const ControlsMap = {
	Controls.NO : "no",
	Controls.CPU : "cpu",
    Controls.KB1 : "kb1",
    Controls.KB2 : "kb2",
    Controls.JOY1 : "joy1",
    Controls.JOY2 : "joy2",
    Controls.JOY3 : "joy3",
    Controls.JOY4 : "joy4"
}
enum SPECIES {MANTIACS, ROBOLORDS, TRIXENS, ANOTHERS}

const SpeciesMap = {
	SPECIES.MANTIACS : "Mantiacs",
	SPECIES.ROBOLORDS : "Robolords",
	SPECIES.TRIXENS : "Trixens",
	SPECIES.ANOTHERS : "Anothers"
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

const species_path : String = "res://selection/species/"

export (Controls) var controls = Controls.KB1 
export (SPECIES) var species = SPECIES.ROBOLORDS


func _ready():
	if controls == Controls.CPU:
		disable_choice()
	change_species(speciesSelection, SpeciesMap[species].to_lower())
	speciesSelection.controls = ControlsMap[controls]
	speciesSelection.initialize(name)
	
	# if CPU or fixed choice
	if disabled:
		disable_choice()
	
	# rotate of the ship and flip it
	

func change_species(species_node, new_species):
	if new_species:
		species_node.change_species(load(species_path + new_species.to_lower() + ".tres"))

func _input(event):
	if disabled:
		return
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
	change_species(speciesSelection, species)
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
	disabled = true
	enabler.visible = true
	speciesSelection.disable()
	

func enable_choice():
	joined = true
	enabler.visible = false
	pass

func unset_commands():
	joined = false
	get_node("VBoxContainer/Controls").unset_commands(global.controls[name.to_lower()])
	controls = Controls.CPU
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
