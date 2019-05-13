tool

extends Node2D

var enabled

export var species : Resource setget set_species
export var player_controls : String
export var player_i : int

func set_species(value):
	species = value
	refresh()
	
func _ready():
	rotation_degrees = -60*player_i
	
	enable()
	refresh()
	
func refresh():
	$Ship/Sprite.texture = (species as SpeciesTemplate).ship
	
signal try_move
signal select
signal cancel
signal proceed

func _input(event):
	if event.is_action_pressed(player_controls+"_cancel"):
		emit_signal('cancel', self)
	elif not enabled and event.is_action_pressed(player_controls+"_accept"):
		emit_signal('proceed', self)
		return
		
	if not enabled:
		return
	if event.is_action_pressed(player_controls+"_down"):
		emit_signal('try_move', self, 'S')
	elif event.is_action_pressed(player_controls+"_up"):
		emit_signal('try_move', self, 'N')
	elif event.is_action_pressed(player_controls+"_left"):
		emit_signal('try_move', self, 'W')
	elif event.is_action_pressed(player_controls+"_right"):
		emit_signal('try_move', self, 'E')
	elif event.is_action_pressed(player_controls+"_accept"):
		emit_signal('select', self)
		
func enable():
	enabled = true
	visible = true
	
func disable():
	enabled = false
	visible = false
	