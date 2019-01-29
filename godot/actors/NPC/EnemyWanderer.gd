extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
export (Vector2) var velocity #  = Vector2(6,6)
var possible_values = [-4, -5, -6, -7, -8, -9, 4, 5, 6, 7, 8, 9]

var stopped = false
var window_size = OS.window_size

func _ready():
	randomize()
	if not velocity:
		velocity = Vector2(randi() % len(possible_values), randi() % len(possible_values))

func _physics_process(delta):
	position += velocity
	if position.x <= 0 or position.x >= window_size.x:
		velocity.x = -velocity.x
	if position.y <= 0 or position.y >= window_size.y:
		velocity.y = -velocity.y
	

