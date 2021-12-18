extends Ball

var charging := false
var speed := 25
var patience := 7

func _ready():
	set_physics_process(true)
	# move the crown slightly to purse a different player each time
	apply_central_impulse(Vector2(1,0).rotated(randf()*2*PI))
	
func start():
	wait_for_charge(patience)
	
func _enter_tree():
	set_physics_process(true)
	
func _physics_process(_delta):
	if charging:
		return
		
	var nearest : Ship = get_nearest_ship()
	if nearest != null:
		apply_central_impulse(speed*(nearest.global_position - global_position).normalized())
	
func wait_for_charge(wait):
	$ChargeTimer.start(wait+randf()*wait)
	
func charge():
	charging = true
	$AnimationPlayer.play('Charge')
	
func dash():
	charging = false
	if patience <= 4 and randf() < 0.18 and len(get_tree().get_nodes_in_group('Negacrown')) < max(2, global.the_game.get_number_of_players()-1):
		var child = load("res://actors/environments/Negacrown.tscn").instance()
		child.global_position = global_position
		child.patience = 6
		get_parent().add_child(child)
		child.start()
		apply_central_impulse(1500*Vector2(1,0).rotated(global_rotation))
		child.apply_central_impulse(-1500*Vector2(1,0).rotated(global_rotation))
	else:
		var nearest : Ship = get_nearest_ship()
		if nearest != null:
			apply_central_impulse(3000*(nearest.get_target_destination() - global_position).normalized())
		patience = max(2, patience-2)
		speed += 10
	wait_for_charge(patience)
	
func get_nearest_ship() -> Ship:
	# pursue the nearest ship
	var ships = global.arena.get_all_valid_ships()
	if len(ships) <= 1: # needed to avoid preferring one ship at start
		return null
	
	var nearest = null
	var distance = 100000000 # Infinity
	for ship in ships:
		# follow the players with more points only
		var leaders = len(global.the_match.get_leader_players())
		var players = global.the_match.get_number_of_players()
		if not (ship.get_player() in global.the_match.get_leader_players()) and leaders < players and leaders != 0:
			continue
		var d = global_position.distance_to(ship.global_position)
		var holdable = ship.get_cargo().get_holdable()
		var already_haunted = holdable != null and holdable is Ball and holdable.has_type('negacrown')
		if d < distance and not already_haunted:
			nearest = ship
			distance = d
			
	return nearest
	
func _on_ChargeTimer_timeout():
	charge()
	
func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == 'Charge':
		$AnimationPlayer.play('Dash')
		dash()
