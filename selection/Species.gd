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

const SpeciesToKey = {
	"mantiacs" : SPECIES.MANTIACS ,
	"robolords" : SPECIES.ROBOLORDS ,
	"trixens" : SPECIES.TRIXENS ,
	"anothers" : SPECIES.ANOTHERS 
}

signal selected
signal deselected
signal leave
signal ready_to_fight
signal prev
signal next

var disabled = false
var selected = false
var joined = true

var index_selection

onready var enabler = $Enabler
onready var speciesSelection = $SpeciesSelection

const species_path : String = "res://selection/species/"

export (Controls) var controls = Controls.KB1 
export (SPECIES) var key_species = SPECIES.ROBOLORDS setget _set_species

var species : String

func initialize():
	pass

func _set_species(new_value:int):
	key_species = new_value
	species = key_to_species(key_species)
	
func key_to_species(key:int) -> String:
	return SpeciesMap[key].to_lower()

func key_to_controls(key:int) -> String:
	return ControlsMap[key]

func _ready():
	species = key_to_species(key_species)
	if controls == Controls.NO or controls == Controls.CPU:
		disable_choice()
	change_species(species)
	speciesSelection.controls = key_to_controls(controls)
	speciesSelection.initialize(name)
	print(name, " ",species)
	

func change_species(new_species:String):
	key_species = SpeciesToKey[new_species]
	_set_species(key_species)
	print(new_species, " ", key_species, " ", name, " ", species)
	if new_species:
		speciesSelection.change_species(load(species_path + species.to_lower() + ".tres"))

func _input(event):
	if disabled:
		return
	var this_control : String = ControlsMap[controls]
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
	emit_signal("leave")

func selected():
	disable_choice()
	selected = true
	change_species(species)
	emit_signal("selected")

func deselect():
	get_node("deselected").play()
	enable_choice()
	selected = false
	emit_signal("deselected")
	
func _on_Previous_pressed():
	emit_signal("prev")
	speciesSelection.previous()

func _on_Next_pressed():
	emit_signal("next")
	speciesSelection.next()

func disable_choice():
	disabled = true
	enabler.visible = true
	speciesSelection.disable()
	
func enable_choice():
	joined = true
	enabler.visible = false

