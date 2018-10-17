extends Control

enum Controls {CPU, KB1, KB2, JOY1, JOY2, JOY3, JOY4}

export (Controls) var controls = KB1
export (String) var left = "A"
export (String) var right = "D"
export (String) var fire = "1"
export (String) var species = "ROBOLORDS"

var side = -1

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
signal ready_to_fight

var disabled = false
var selected = false
var joined = false

var index_selection

onready var controls_label=$VBoxContainer/Controls/Label
onready var controls_container=$VBoxContainer/Controls/CenterContainer
onready var character_container=$VBoxContainer/MarginContainer/HBoxContainer/CharacterContainer
onready var characterSprite = $VBoxContainer/MarginContainer/HBoxContainer/CharacterContainer/Sprite
onready var selRectSprite = $VBoxContainer/MarginContainer/HBoxContainer/CharacterContainer/SelRect

onready var enabler = get_node("enabler")

func _ready():
	
	# setting controls for the right species
	$VBoxContainer/Controls/CenterContainer/HBoxContainer/Right/CenterContainer/Panel/Key.text = right
	$VBoxContainer/Controls/CenterContainer/HBoxContainer/Left/CenterContainer/Panel/Key.text = left
	$VBoxContainer/Controls/CenterContainer/HBoxContainer/Fire/CenterContainer/Panel/Key.text = fire
	
	# Called when the node is added to the scene for the first time.
	# Initialization here
	var ship = $VBoxContainer/CenterContainer/NinePatchRect/Sprite
	
	ship.position = Vector2(50,50)
	ship.scale = Vector2(0.5, 0.5)
	characterSprite.position = Vector2(65,200)
	characterSprite.scale = Vector2(0.43, 0.43)
	selRectSprite.position = Vector2(65,200)
	selRectSprite.scale = Vector2(0.43, 0.43)
	
	# adjust selection rect position if flipped
	if side != 0:
		selRectSprite.position = Vector2(55,200)
	
	# set species from available_species
	species = global.chosen_species[name.to_lower()]
	index_selection = global.available_species.find(species)
	print(name , " is ", species)
	
	change_species(species)
	
	# if CPU or fixed choice
	if disabled:
		disable_choice()
	
	# rotate of the ship and flip it
	if side != 0:
		ship.get_node("AnimationPlayer").play("standby")
	else:
		ship.get_node("AnimationPlayer").play_backwards("standby")
	
	ship.flip_h = not side
	characterSprite.flip_h = side
	
	# set controls to keyboard 2 if flipped
	if side != 0:
		$VBoxContainer/Controls/Label.text = ControlsMap[controls]

func change_species(new_species):
	# print(name,": ", species," new_species->", new_species," index-> ",index_selection,global.chosen_species)
	species = new_species.to_lower()
	var ship = $VBoxContainer/CenterContainer/NinePatchRect/Sprite
	$VBoxContainer/SpeciesName.text = species.to_upper()
	ship.texture = load("res://actors/"+species+"_ship.png")
	characterSprite.texture = load("res://assets/character_"+species+"_1.png")
	selRectSprite.texture = load("res://assets/character_selection_rect_"+species+".png")
	

func _input(event):
	var this_control = ControlsMap[controls]
	if selected and event.is_action_pressed(this_control+"_fire"):
		emit_signal("ready_to_fight")
	if joined:
		if event.is_action_pressed(this_control+"_right") and not selected:
			_on_Next_pressed()
		if event.is_action_pressed(this_control+"_left") and not selected:
			_on_Previous_pressed()
		if event.is_action_pressed(this_control+"_fire") and not selected:
			disable_choice()
			selected = true
			global.chosen_species[name.to_lower()] = species
			change_species(species)
			global.available_species.remove(global.available_species.find(species))
			emit_signal("selected")
	
func selected():
	selRectSprite.visible = true

func _on_Previous_pressed():
	
	var a = index_selection - 1
	var b = len(global.available_species)
	index_selection = mod(a,b)

	change_species(global.available_species[index_selection])


func _on_Next_pressed():
	var a = index_selection + 1
	var b = len(global.available_species)
	index_selection = mod(a,b)

	change_species(global.available_species[index_selection])

func disable_choice():
	$VBoxContainer/MarginContainer/HBoxContainer/Previous.disabled = true
	$VBoxContainer/MarginContainer/HBoxContainer/Next.disabled = true
	$VBoxContainer/MarginContainer/HBoxContainer/Previous.visible = false
	$VBoxContainer/MarginContainer/HBoxContainer/Next.visible = false
	controls_container.visible = false

func enable_choice():
	joined = true
	enabler.visible = false
	$VBoxContainer/MarginContainer/HBoxContainer/Previous.disabled = false
	$VBoxContainer/MarginContainer/HBoxContainer/Next.disabled = false
	$VBoxContainer/MarginContainer/HBoxContainer/Previous.visible = true
	$VBoxContainer/MarginContainer/HBoxContainer/Next.visible = true
	controls_container.visible = true

func set_commands(button):
	joined = true
	for control in ControlsMap:
		if ControlsMap[control] in button:
			controls = control
			# update globals
			global.controls[name.to_lower()] = ControlsMap[control]
			enable_choice()
	
func mod(a,b):
	var ret = a%b
	if ret < 0: 
		return ret+b
	else:
		return ret
