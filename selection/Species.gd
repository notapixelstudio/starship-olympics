extends Control

class_name Species

var id:String
var uid:int
var species_template : SpeciesSelection

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
const controlsToKey = {
	"no" : Controls.NO,
	"cpu" : Controls.CPU,
    "kb1" : Controls.KB1,
    "kb2" : Controls.KB2,
    "joy1" : Controls.JOY1,
    "joy2" : Controls.JOY2,
    "joy3" : Controls.JOY3,
    "joy4" : Controls.JOY4
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
const BATTLER_PATH = "res://actors/battlers/characters/" 

signal selected
signal deselected
signal leave
signal ready_to_fight
signal prev
signal next

var disabled = false
var selected = false
var joined = true

onready var speciesSelection = $SpeciesSelection
onready var sfx = $SFX

const species_path : String = "res://selection/species/"

export (Controls) var key_controls = Controls.KB1 setget _set_controls_by_key
export (SPECIES) var key_species = SPECIES.ROBOLORDS setget _set_species
export (String, "", "kb1", "kb2") var force_to

var species : String
var controls : String
var battler_template : BattlerTemplate

func initialize():
	pass

func _set_species(new_value:int):
	
	key_species = new_value
	species = key_to_species(key_species)
	
func key_to_species(key:int) -> String:
	return SpeciesMap[key].to_lower()

func key_to_controls(key:int) -> String:
	return ControlsMap[key]
	
func set_controls(new_controls:String):
	"""
	Set controls and disable if NO or CPU
	"""
	if key_controls == Controls.NO or key_controls == Controls.CPU:
		disable_choice()
	else:
		enable_choice()
	speciesSelection.controls = controls
	speciesSelection.initialize(name)
	
func set_controls_by_string(new_controls:String):
	controls = new_controls
	key_controls = controlsToKey[controls]
	set_controls(controls)
	
func _set_controls_by_key(new_controls:int):
	key_controls = new_controls
	controls = key_to_controls(key_controls)
	set_controls(controls)
	
func _ready():
	species = key_to_species(key_species)
	change_species(species)
	id = name.to_lower()
	print("ID is ", id)
	speciesSelection.initialize(name)

func change_species(new_species:String):
	key_species = SpeciesToKey[new_species]
	_set_species(key_species)
	if new_species:
		species_template = load(species_path + species.to_lower() + ".tres")
		speciesSelection.change_species(species_template)

func _input(event):
	if disabled:
		return
	if selected :
		if event.is_action_pressed(controls+"_fire"):
			emit_signal("ready_to_fight")
		elif event.is_action_pressed(controls+"_action"):
			deselect()
	elif joined:
		if event.is_action_pressed(controls+"_right") and not selected:
			_on_Next_pressed()
		if event.is_action_pressed(controls+"_left") and not selected:
			_on_Previous_pressed()
		if event.is_action_pressed(controls+"_fire") and not selected:
			select_character()
		if event.is_action_pressed(controls+"_action") and not selected:
			leave()
	elif force_to and event.is_action_pressed(force_to+"_fire"):
		set_controls_by_string(force_to)
		print("forcing to" + force_to)
		return


func leave():
	joined = false
	speciesSelection.modulate = Color(0.3,0.3,0.3,1)
	disable_choice()
	emit_signal("leave")

func select_character():
	selected = true
	speciesSelection.select()
	battler_template = load(BATTLER_PATH + species + ".tres")
	emit_signal("selected", species)

func deselect():
	print("deselected")
	speciesSelection.deselect()
	sfx.get_node("deselected").play()
	enable_choice()
	selected = false
	emit_signal("deselected", species)
	
func _on_Previous_pressed():
	emit_signal("prev")
	speciesSelection.previous()

func _on_Next_pressed():
	emit_signal("next")
	speciesSelection.next()

func disable_choice():
	disabled = true
	speciesSelection.modulate = Color(0.3,0.3,0.3,1)
	speciesSelection.disable()
	
func enable_choice():
	joined = true
	disabled = false
	speciesSelection.modulate = Color(1,1,1,1)
	speciesSelection.enable()

