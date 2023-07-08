extends Node2D

@export var starting_screen_scene : PackedScene

var screens_stack := []  # Array of ScreenScene to navigate back

signal transition

func _ready():
	navigate_to(starting_screen_scene)

func navigate_to(screen_scene: PackedScene):
	var from_screen_id = 'start'
	if len(screens_stack) > 0:
		var active_screen = screens_stack[-1]
		disconnect_nav_signals(active_screen)
		active_screen.exit()
		from_screen_id = active_screen.get_id()
	
	var new_screen = screen_scene.instantiate() as Screen
	assert(new_screen is Screen)
	#if len(screens_stack) > 0:
	#	from=screens_stack[-1].name
	add_child(new_screen)
	new_screen.position.x = 1280 * len(screens_stack)
	screens_stack.append(new_screen)
	var to_screen_id = new_screen.get_id()
	emit_signal('transition', 'navigate_to', from_screen_id, to_screen_id)
	var new_camera_position_x = 1280 * (len(screens_stack)-1)
	print(screens_stack)
	if new_camera_position_x != $Camera2D.position.x: # move camera if needed
		var tween := create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		tween.tween_property($Camera2D, 'position:x', new_camera_position_x, 1)
		await tween.finished
	
	connect_nav_signals(new_screen)
	new_screen.enter()
	
	
func back():
	var old_screen = screens_stack.pop_back()
	disconnect_nav_signals(old_screen)
	var from_screen_id = old_screen.get_id()
	old_screen.exit()
	var active_screen = screens_stack[-1]
	connect_nav_signals(active_screen)
	emit_signal('transition', 'back', from_screen_id, active_screen.get_id())
	
	var tween := create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property($Camera2D, 'position:x', 1280 * (len(screens_stack)-1), 1)
	await tween.finished
	
	old_screen.queue_free()
	active_screen.enter()

func connect_nav_signals(screen : Screen) -> void:
	(screen as Screen).connect("next", Callable(self, "navigate_to"))
	(screen as Screen).connect("back", Callable(self, "back"))
	
func disconnect_nav_signals(screen : Screen) -> void:
	if (screen as Screen).is_connected("next", Callable(self, "navigate_to")):
		(screen as Screen).disconnect("next", Callable(self, "navigate_to"))
	if (screen as Screen).is_connected("back", Callable(self, "back")):
		(screen as Screen).disconnect("back", Callable(self, "back"))
