extends Node2D

var owner_ship: Ship

func _ready():
	owner_ship = get_parent() # WARNING
	
var held = null
var just_dropped := false
func load_holdable(holdable) -> void:
	# refuse to reload a holdable if sth has just been dropped!
	if just_dropped:
		return
		
	# refuse to reload a holdable that's already loaded
	if holdable == held:
		return
		
	if has_holdable():
		drop_holdable()
		
	held = holdable
	show_holdable()
	Events.emit_signal("holdable_loaded", held, owner_ship)

func has_holdable() -> bool:
	return held != null
	
func set_holdable(holdable):
	"""
		Low-level set of a cargo holdable. Do not call to load a holdable. Call 'load_holdable' instead.
	"""
	held = holdable
	
func get_holdable():
	return held
	
func drop_holdable():
	if not self.has_holdable():
		return
		
	var holdable = held
	held = null
	holdable.place_and_push(owner_ship, owner_ship.previous_velocity) # previous is needed for glass
	hide_holdable()
	Events.emit_signal("holdable_dropped", holdable, owner_ship)
	
	# disable loading for a while, to avoid reloading a holdable right after drop
	just_dropped = true
	yield(get_tree().create_timer(0.5), "timeout") # maybe we should use a Timer node, to enable canceling
	just_dropped = false
	
func show_holdable():
	if held != null:
		$Sprite.texture = held.get_texture()
		$Sprite.position = Vector2(Ball.GRAB_DISTANCE, 0)

func hide_holdable():
	$Sprite.texture = null
	$Sprite.position = Vector2(0,0)
