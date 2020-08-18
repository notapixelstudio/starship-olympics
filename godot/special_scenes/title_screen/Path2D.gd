extends Path2D

onready var follow = $PathFollow2D
export var trail_scene : PackedScene
onready var ship = $PathFollow2D/Sprite
onready var trail = $PathFollow2D/Sprite/Trail

var all_species = []
var all_speed = [150, 120, 200, 130, 140]
var speed = 140
func _ready():
	randomize()
	
	for species_name in global.get_unlocked():
		all_species.append(load(global.SPECIES_PATH+'/'+species_name+'.tres'))
	
	init_ship()
	
func _process(delta):
	follow.offset += speed*delta
	if follow.unit_offset > 0.9: 
		init_ship()
		follow.offset = 0.0

func init_ship():
	var species = all_species[randi() % len(all_species)]
	ship.species = species
	ship.texture = species.ship_off
	speed = all_speed[randi() % len(all_speed)]
	trail.initialize(ship)
