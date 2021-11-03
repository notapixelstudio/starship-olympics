extends Ball

func _ready():
	set_physics_process(true)
	# move the crown slightly to purse a different player each time
	apply_central_impulse(Vector2(1,0).rotated(randf()*2*PI))
	
func _enter_tree():
	set_physics_process(true)
	
func _physics_process(_delta):
	# pursue the nearest ship
	var ships = global.arena.get_all_valid_ships()
	if len(ships) <= 1: # needed to avoid preferring one ship at start
		return
	
	var near = ships[0]
	var distance = global_position.distance_to(near.global_position)
	for ship in ships:
		var d = global_position.distance_to(ship.global_position)
		if d < distance:
			near = ship
			distance = d
	
	apply_central_impulse(20*(near.global_position - global_position).normalized())
