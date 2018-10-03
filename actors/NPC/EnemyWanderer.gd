extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
export (Vector2) var velocity = Vector2(6,6)

var stopped = false
var window_size = OS.window_size

func _ready():
	if not velocity:
		velocity = Vector2()

func _physics_process(delta):
	position += velocity
	if position.x <= 0 or position.x >= window_size.x:
		velocity.x = -velocity.x
	if position.y <= 0 or position.y >= window_size.y:
		velocity.y = -velocity.y
	

