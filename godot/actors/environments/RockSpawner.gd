extends PathFollow2D

onready var Rock = preload('res://actors/environments/Rock.tscn')

export var period = 2
export var spawn_diamonds_chance = 0.0
export var order = 2
export var speed = 1200

signal spawn

func _ready():
	set_unit_offset(randf())

func start():
	$Timer.wait_time = period
	$Timer.start()
	spawn()
	
func _on_Timer_timeout():
	spawn()
	
func spawn():
	var rock = Rock.instance()
	rock.position = global_position
	rock.spawn_diamonds = randf() < spawn_diamonds_chance
	rock.order = order
	emit_signal('spawn', rock)
	
func _process(delta):
	offset += speed*delta
	
