extends Area2D

export var sector_scene : PackedScene
export var inner_radius := 100.0
export var outer_radius := 200.0
export var sectors := 2
export var padding := 0.0
export var angle_speed := PI/5

var sector_children := []

func _ready():
	var angle = TAU/sectors
	for i in range(sectors):
		var sector = sector_scene.instance()
		sector.inner_radius = inner_radius
		sector.outer_radius = outer_radius
		sector.angle = angle
		sector.rotation = angle*i
		sector.position = Vector2(0, padding).rotated(sector.rotation)
		add_child(sector)
		sector_children.append(sector)
		
func _process(delta):
	rotation += delta * angle_speed

func up():
	for sector in sector_children:
		sector.up()

func down():
	for sector in sector_children:
		sector.down()
		
