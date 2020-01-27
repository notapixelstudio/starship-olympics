tool

extends Node2D

var enabled

export var species : Resource setget set_species
export var player : Resource
export var player_i : int
export var cell_size : int
export var grid_position : Vector2 setget set_grid_position

onready var move_tween = $MoveTween

func set_grid_position(value):
	grid_position = value
	
	if is_inside_tree():
		# tween to target position
		move_tween.interpolate_property(self, 'position',
			self.position, cell_size * grid_position, 0.5,
			Tween.TRANS_SINE, Tween.EASE_OUT)
		move_tween.start()
	else:
		position = cell_size * grid_position

func set_species(value):
	species = value
	
func _ready():
	rotation_degrees = -60*player_i
	
	enable()
	$Ship/Sprite.texture = (species as SpeciesTemplate).ship
	$Ship/LabelContainer/Label.text = "P" + str(player_i+1)
	
signal try_move
signal select
signal cancel
signal proceed

func _input(event):
	if event.is_action_pressed(player.controls+"_cancel"):
		emit_signal('cancel', self)
	elif not enabled and event.is_action_pressed(player.controls+"_accept"):
		emit_signal('proceed', self)
		return
		
	if not enabled:
		return
	if event.is_action_pressed(player.controls+"_down"):
		emit_signal('try_move', self, 'S')
	elif event.is_action_pressed(player.controls+"_up"):
		emit_signal('try_move', self, 'N')
	elif event.is_action_pressed(player.controls+"_left"):
		emit_signal('try_move', self, 'W')
	elif event.is_action_pressed(player.controls+"_right"):
		emit_signal('try_move', self, 'E')
	elif event.is_action_pressed(player.controls+"_accept"):
		emit_signal('select', self)
		
func enable():
	enabled = true
	visible = true
	
func disable():
	enabled = false
	visible = false
	
func _process(delta):
	$Ship/LabelContainer.rotation = -$Ship.rotation - rotation
	