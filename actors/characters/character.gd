extends KinematicBody2D

var direction = Vector2()

const WALK = "walk"
const IDLE = "idle"
const SETUP = "setup"
const ATTACK = "attack"
const DIE = "die"
const STAGGER = "stagger"

const TOP = Vector2(0, -1)
const RIGHT = Vector2(1, 0)
const DOWN = Vector2(0, -1)
const LEFT = Vector2(-1, 0)

#condition of being alive
var taken = false
const MAX_SPEED = 0.5

var speed = 0
var velocity = Vector2()

var target_pos = Vector2()
var is_moving = false

var type
var side
var state
var battlefield

# Structure of the piece
var piece_name
var moves
var legal_moves
var pos_in_the_grid
var target_pos_in_the_grid
var taken_pos

export var baseScale = 1
onready var representation = get_node("AnimationPlayer")
onready var pivot = get_node("Pivot")

func _ready():
	representation.play(SETUP)
	battlefield = get_parent()
	representation.play("summon")

func animate(keyword):
	representation.play(keyword)

func face_left():
	pivot.scale = Vector2(-baseScale, baseScale)

func face_right():
	pivot.scale = Vector2(baseScale, baseScale)
	
func _physics_process(delta):
	speed = 0
	
	if Input.is_action_just_pressed("ui_up"):
		direction.y = -1
	elif Input.is_action_just_pressed("ui_down"):
		direction.y = 1

	if Input.is_action_just_pressed("ui_left"):
		direction.x = -1
	elif Input.is_action_just_pressed("ui_right"):
		direction.x = 1

	if not is_moving and target_pos != Vector2():
		# Actually I think target_pos cannot be NON vacant
		# if battlefield.is_cell_vacant(position, target_pos):
		# target_pos = battlefield.update_child_pos(self)
		is_moving = true
	elif is_moving:
		speed = MAX_SPEED
		velocity = speed * direction
		var pos = position
		var distance_to_target = Vector2(abs(target_pos.x - position.x), abs(target_pos.y - pos.y))
		if distance_to_target == Vector2():
			is_moving = false
		if abs(velocity.x) > distance_to_target.x: 
			velocity.x = distance_to_target.x * target_pos.x
			is_moving = false
			target_pos = Vector2()
		if abs(velocity.y) > distance_to_target.y: 
			velocity.y = distance_to_target.y * target_pos.y
			is_moving = false
			target_pos = Vector2()
		move_and_collide(velocity)
