extends Control

class_name PlayerSelection

"""
Class for PlayerSelection logic. Will be set controls and Species template
"""

var uid:int

# enum duplicates in global
enum CONTROLS {KB1, KB2, JOY1, JOY2, JOY3, JOY4,RM1, RM2,RM3,RM4, NO, CPU}

signal selected
signal deselected
signal leave
signal ready_to_fight
signal prev
signal next

var disabled = true
var selected = false 
var joined = true

onready var wrapper = $Wrapper
onready var speciesSelection = $Wrapper/SpeciesSelection
onready var sfx = $SFX

const species_path : String = "res://selection/species/"

export (CONTROLS) var key_controls = CONTROLS.KB1
export (String, "", "kb1", "kb2") var force_to
export (Resource) var species # : SpeciesTemplate

# this will be the String of controls
var controls : String
var is_team : bool = false
signal ready_takeoff

onready var info: InfoPlayer = InfoPlayer.new()

func get_ship_position():
	return rect_position

func get_info_player() -> InfoPlayer:
	return self.info
	
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
	speciesSelection.post_ready("P"+str(uid))
	
func _ready():
	info.set_id(name.to_lower())
	
	disabled = true
	controls = global.CONTROLSMAP[key_controls]
	
	set_controls(controls)
	change_species(species)

func change_species(new_species):
	# get the resource from the global
	if new_species:
		species = new_species
		speciesSelection.change_species(species)

const FIRST_DELAY = 0.4
const FOLLOW_DELAY = 0.2
const DEADZONE = 0.1
var action_time = 0.0

func _process(delta):
	if "no" in controls:
		return
	if action_time >= 0.0:
		action_time -= delta
	if Input.is_action_just_pressed(controls+"_right") and Input.get_action_strength(controls+"_right") > DEADZONE and not global.demo:
		_on_Next_pressed()
		action_time = FIRST_DELAY
	if Input.is_action_just_pressed(controls+"_left") and Input.get_action_strength(controls+"_left") > DEADZONE and not global.demo:
		_on_Previous_pressed()
		action_time = FIRST_DELAY
		
	if Input.is_action_pressed(controls+"_right") and Input.get_action_strength(controls+"_right") > DEADZONE and not global.demo and action_time <= 0.0:
		_on_Next_pressed()
		action_time = FOLLOW_DELAY
	elif Input.is_action_pressed(controls+"_left") and Input.get_action_strength(controls+"_left") > DEADZONE and not global.demo and action_time <= 0.0:
		_on_Previous_pressed()
		action_time = FOLLOW_DELAY
		
func _input(event):
	if disabled:
		return
	if selected:
		if event.is_action_pressed(controls+"_fire"):
			sfx.get_node("ready").play()
			emit_signal("ready_to_fight")
#		elif event.is_action_pressed(controls+"_cancel") and not global.demo:
#			deselect()
	elif joined:
		if event.is_action_pressed(controls+"_fire") and not selected:
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
	wrapper.z_index = 1000
	speciesSelection.select()
	sfx.get_node("voice").set_stream(species.voice)
	sfx.get_node("voice").play()
	#sfx.get_node("selected").play()
	setup_info()
	emit_signal("selected", self)

func setup_info():
	info.controls = controls
	info.species = species
	
func deselect(silent : bool = false):
	speciesSelection.deselect()
	unset_team()
	#if not silent:
	#	sfx.get_node("deselected").play()
	enable_choice(silent)
	selected = false
	wrapper.z_index = 0
	emit_signal("deselected", species)
	
func _on_Previous_pressed():
	switch_selection()
	emit_signal("prev")

func _on_Next_pressed():
	switch_selection()
	emit_signal("next")
	
func switch_selection():
	if selected:
		enable_choice()
		selected = false
		wrapper.z_index = 0
		emit_signal("deselected", species)
	else:
		sfx.get_node("switch-selection").play()

func disable_choice():
	disabled = true
	speciesSelection.modulate = Color(0.3,0.3,0.3,1)
	speciesSelection.disable()
	
func enable_choice(silent=false):
	joined = true
	disabled = false
	speciesSelection.modulate = Color(1,1,1,1)
	selected = false
	wrapper.z_index = 0
	speciesSelection.enable(silent)
	if global.demo:
		speciesSelection.disable_arrows()
	
