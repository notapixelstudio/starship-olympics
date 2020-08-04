extends Control

class_name PlayerSelection

"""
Class for Species logic. Will be set controls and Species template
"""

var id:String
var uid:int

# enum duplicates in global
enum CONTROLS {KB1, KB2, JOY1, JOY2, JOY3, JOY4, NO, CPU}

signal selected
signal deselected
signal leave
signal ready_to_fight
signal prev
signal next

var disabled = true
var selected = false 
var joined = true

onready var speciesSelection = $SpeciesSelection
onready var sfx = $SFX

const species_path : String = "res://selection/species/"

export (CONTROLS) var key_controls = CONTROLS.KB1
export (String, "", "kb1", "kb2") var force_to
export (Resource) var species # : SpeciesTemplate

# this will be the String of controls
var controls : String
var is_team : bool = false

func set_controls(new_controls:String):
	"""
	Set controls and disable if NO or CPU
	"""
	deselect(true)
	var k_controls = global.CONTROLSMAP_TO_KEY[new_controls]
	controls = new_controls
	if k_controls == CONTROLS.NO or k_controls == CONTROLS.CPU:
		disable_choice()
	
	speciesSelection.controls = controls
	speciesSelection.initialize("P"+str(uid))
	
var info # : InfoPlayer
func _ready():
	info = InfoPlayer.new()
	info.id = name.to_lower()
	
	disabled = true
	controls = global.CONTROLSMAP[key_controls]
	set_controls(controls)
	change_species(species)
	id = name.to_lower()
	speciesSelection.initialize("P"+str(uid))

func change_species(new_species):
	# get the resource from the global
	if new_species:
		species = new_species
		speciesSelection.change_species(species)

const FIRST_DELAY = 0.4
const FOLLOW_DELAY = 0.2

var action_time = 0.0
func _process(delta):
	if action_time >= 0.0:
		action_time -= delta
	if Input.is_action_just_pressed(controls+"_right") and not global.demo:
		_on_Next_pressed()
		action_time = FIRST_DELAY
	if Input.is_action_just_pressed(controls+"_left") and not global.demo:
		_on_Previous_pressed()
		action_time = FIRST_DELAY
		
	if Input.is_action_pressed(controls+"_right") and not global.demo and action_time <= 0.0:
		_on_Next_pressed()
		action_time = FOLLOW_DELAY
	elif Input.is_action_pressed(controls+"_left") and not global.demo and action_time <= 0.0:
		_on_Previous_pressed()
		action_time = FOLLOW_DELAY
		
func _input(event):
	if disabled:
		return
	if selected :
		if event.is_action_pressed(controls+"_accept"):
			emit_signal("ready_to_fight")
#		elif event.is_action_pressed(controls+"_cancel") and not global.demo:
#			deselect()
	elif joined:
		if event.is_action_pressed(controls+"_accept") and not selected:
			select_character()

func set_team(team_name: String):
	var condition = not disabled
	if not disabled:
		speciesSelection.set_team(team_name)
		if selected:
			is_team = true
	return condition

func unset_team():
	var condition = not disabled
	if not disabled:
		speciesSelection.unset_team()
		is_team = false
	return condition
	
func leave():
	joined = false
	speciesSelection.modulate = Color(0.3,0.3,0.3,1)
	disable_choice()
	emit_signal("leave")

func select_character():
	selected = true
	speciesSelection.select()
	sfx.get_node("selected").play()
	setup_info()
	emit_signal("selected", self)

func setup_info():
	info.species_name = species.species_name
	info.controls = controls
	info.species = species
	
func deselect(silent : bool = false):
	speciesSelection.deselect()
	unset_team()
	if not silent:
		sfx.get_node("deselected").play()
	enable_choice()
	selected = false
	emit_signal("deselected", species)
	
func _on_Previous_pressed():
	sfx.get_node("switch-selection").play()
	if selected:
		enable_choice()
		selected = false
		emit_signal("deselected", species)
	emit_signal("prev")

func _on_Next_pressed():
	sfx.get_node("switch-selection").play()
	if selected:
		enable_choice()
		selected = false
		emit_signal("deselected", species)
	emit_signal("next")

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
	if global.demo:
		speciesSelection.disable_arrows()
	
