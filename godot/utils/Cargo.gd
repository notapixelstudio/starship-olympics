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
		
	var replaced = null
	if has_holdable():
		# refuse to load a holdable of the same type
		if holdable.is_equivalent_to(held):
			return
		
		replaced = held
		drop_holdable(replaced)
		
	held = holdable
	show_holdable()
	if traits.has_trait(holdable, 'Owned'):
		holdable.set_player(owner_ship.get_player())
	Events.emit_signal("holdable_loaded", held, owner_ship)
	
	if replaced != null:
		Events.emit_signal("holdable_replaced", replaced, held, owner_ship)

func has_holdable() -> bool:
	return held != null
	
func set_holdable(holdable):
	"""
		Low-level set of a cargo holdable. Do not call to load a holdable. Call 'load_holdable' instead.
	"""
	held = holdable
	if traits.has_trait(holdable, 'Owned'):
		holdable.set_player(owner_ship.get_player())
	
func get_holdable():
	return held
	
func drop_holdable(cause):
	if not self.has_holdable():
		return

	var direction : String
	if traits.has_trait(cause, "Holdable"):
		direction = 'backward' # avoid juggling
	elif traits.has_trait(cause, "Dropper") or cause is Wall and cause.type == Wall.TYPE.glass:
		direction = 'forward' # no-zones will rebound
	elif cause == owner_ship:
		direction = 'forward' # upon death, cargo is dropped forward
	else:
		direction = 'forward'
		
	var holdable = held
	held = null
	var previous_velocity = owner_ship.previous_velocity
	if previous_velocity.length() < 1.0: # push if the ship was still
		previous_velocity = Vector2(200.0, 0).rotated(owner_ship.global_rotation)
		
	if cause is Pew: # FIXME all weapons?
		previous_velocity = cause.get_previous_velocity()
		
	holdable.place_and_push(owner_ship, previous_velocity, direction) # previous is needed for glass
	hide_holdable()
	Events.emit_signal("holdable_dropped", holdable, owner_ship, cause)
	
	# disable loading for a while, to avoid reloading a holdable right after drop
	just_dropped = true
	yield(get_tree().create_timer(0.5), "timeout") # maybe we should use a Timer node, to enable canceling
	just_dropped = false
	
func show_holdable():
	if held != null:
		$Wrapper/Sprite.texture = held.get_texture()
		$Wrapper/Shadow.texture = held.get_texture()
		if held.show_on_top():
			$Wrapper/Sprite.z_index = 100
			$Wrapper/Sprite.z_as_relative = false
			$Wrapper.position = Vector2(0, -Ball.GRAB_DISTANCE*1.5)
			$RoyalGlow.position.x = 0
		else:
			var grab_distance = Ball.GRAB_DISTANCE * (1.5 if held.has_type('skull') else 1.0)
			$Wrapper.position = Vector2(grab_distance, 0)
			$RoyalGlow.position.x = 75
			
		if held.is_glowing():
			$RoyalGlow.visible = true
			
		if held is Alien:
			$Wrapper.position = Vector2(Ball.GRAB_DISTANCE * 1.7, 0)
		
		$Wrapper/Sprite.scale = Vector2(1.3, 1.3) if held is Alien else Vector2(1,1)
		$Wrapper/Shadow.scale = Vector2(1.3, 1.3) if held is Alien else Vector2(1,1)

func hide_holdable():
	$Wrapper/Sprite.texture = null
	$Wrapper.position = Vector2(0,0)
	$Wrapper/Sprite.z_index = 0
	$Wrapper/Sprite.z_as_relative = true
	$RoyalGlow.visible = false

func _process(delta):
	if held != null and not held.is_rotatable():
		$Wrapper/Sprite.rotation = -global_rotation
		$Wrapper/Shadow.rotation = -global_rotation
		$Wrapper/Shadow.position = Vector2(0, 32).rotated(-global_rotation)
		if held.show_on_top():
			var grab_distance = Ball.GRAB_DISTANCE * (2.0 if held.has_type('bee_crown') else 1.5)
			$Wrapper.position = Vector2(0, -grab_distance).rotated(-global_rotation)

func empty():
	if held != null:
		held.free()
		held = null
		hide_holdable()
	
func check_type(t):
	if not self.has_holdable():
		return false
	
	return self.get_holdable().has_type(t)
	
func check_class(klass):
	if not self.has_holdable():
		return false
	
	return self.get_holdable() is klass
	
