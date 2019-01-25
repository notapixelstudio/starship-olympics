extends Control

class_name Species

var id:String
var uid:int
var species_template : SpeciesTemplate

# enum duplicates in global
enum CONTROLS {KB1, KB2, JOY1, JOY2, JOY3, JOY4, NO, CPU}
enum ALL_SPECIES {SPECIES0, SPECIES1, SPECIES2, SPECIES3, SPECIES4}

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

export (CONTROLS) var key_controls = CONTROLS.KB1
export (ALL_SPECIES) var species  = ALL_SPECIES.SPECIES0 
export (String, "", "kb1", "kb2") var force_to

var controls : String
var species_templates : Dictionary # Dict[String, Resource]

func set_controls(new_controls:String):
	"""
	Set controls and disable if NO or CPU
	"""
	if key_controls == CONTROLS.NO or key_controls == CONTROLS.CPU:
		deselect()
		disable_choice()
	else:
		deselect()
	speciesSelection.controls = controls
	speciesSelection.initialize(name)
	
func _set_controls_by_key(new_controls:int):
	key_controls = new_controls
	controls = global.CONTROLSMAP[key_controls]
	set_controls(controls)
	
func _ready():
	species_templates = global.get_species_templates()
	species_template = species_templates[species]
	_set_controls_by_key(key_controls)
	change_species(species)
	id = name.to_lower()
	print("ID is ", id)
	speciesSelection.initialize(name)

func change_species(new_species:int):
	# get the resource from the global
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


func leave():
	joined = false
	speciesSelection.modulate = Color(0.3,0.3,0.3,1)
	disable_choice()
	emit_signal("leave")

func select_character():
	selected = true
	speciesSelection.select()
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
	selected = false
	speciesSelection.enable()

