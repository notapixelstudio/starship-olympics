tool

extends Node2D

var enabled

export var species : Resource setget set_species
export var player : Resource
export var player_i : int
export var cell_size : int
export var grid_position : Vector2 setget set_grid_position

onready var move_tween = $MoveTween
onready var animation_player = $Graphics/AnimationPlayer
onready var ship = $Graphics/Ship
onready var placemark = $Graphics/Placemark
onready var label = $Graphics/LabelContainer/Label

var wait = 0

func set_grid_position(value):
	grid_position = value
	
	if is_inside_tree():
		# tween to target position
		move_tween.interpolate_property(self, 'position',
			self.position, cell_size * grid_position, 0.25,
			Tween.TRANS_QUAD, Tween.EASE_OUT)
		move_tween.start()
	else:
		position = cell_size * grid_position

func set_species(value):
	species = value
	
func _ready():
	enable()
	ship.texture = (species as SpeciesTemplate).ship
	label.text = "P" + str(player_i+1)
	placemark.modulate = (species as SpeciesTemplate).color
	ship.rotation = -rotation - PI/2
	$Graphics/LabelContainer.rotation = -rotation
	
	yield(get_tree().create_timer(wait), "timeout")
	animation_player.play('Float')
	
signal try_move
signal select
signal cancel
signal proceed

func _process(delta):
	if Input.is_action_just_pressed(player.controls+"_cancel"):
		emit_signal('cancel', self)
	elif not enabled and Input.is_action_just_pressed(player.controls+"_accept"):
		emit_signal('proceed', self)
		return
		
	if not enabled:
		return
	if Input.is_action_just_pressed(player.controls+"_down"):
		emit_signal('try_move', self, 'S')
	elif Input.is_action_just_pressed(player.controls+"_up"):
		emit_signal('try_move', self, 'N')
	elif Input.is_action_just_pressed(player.controls+"_left"):
		emit_signal('try_move', self, 'W')
	elif Input.is_action_just_pressed(player.controls+"_right"):
		emit_signal('try_move', self, 'E')
	elif Input.is_action_just_pressed(player.controls+"_accept"):
		emit_signal('select', self)
		
func enable():
	enabled = true
	visible = true
	
func disable():
	enabled = false
	visible = false
	