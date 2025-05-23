extends Node2D

@export var starting_screen_scene : PackedScene

var screens_stack := []  # Array of ScreenScene to navigate back

signal transition_started(action:String, from:String, to:String)
signal transition_ended(action:String, from:String, to:String)

func _ready():
	navigate_to(starting_screen_scene.instantiate())

func navigate_to(new_screen: Screen):
	var from_screen_id = 'start'
	var old_screen = null
	if len(screens_stack) > 0:
		old_screen = screens_stack[-1]
		disconnect_nav_signals(old_screen)
		old_screen.exiting()
		from_screen_id = old_screen.get_id()
	
	add_child(new_screen)
	new_screen.position.x = 1280 * len(screens_stack)
	screens_stack.append(new_screen)
	var to_screen_id = new_screen.get_id()
	transition_started.emit('navigate_to', from_screen_id, to_screen_id)
	var new_camera_position_x = 1280 * (len(screens_stack)-1)
	print(screens_stack)
	if new_camera_position_x != $Camera2D.position.x: # move camera if needed
		var tween := create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		tween.tween_property($Camera2D, 'position:x', new_camera_position_x, 1)
		await tween.finished
	
	if old_screen != null:
		old_screen.exited()
	transition_ended.emit('navigate_to', from_screen_id, to_screen_id)
	
	connect_nav_signals(new_screen)
	new_screen.enter()
	
	
func back():
	var old_screen = screens_stack.pop_back()
	disconnect_nav_signals(old_screen)
	var from_screen_id = old_screen.get_id()
	old_screen.exiting()
	var active_screen = screens_stack[-1]
	connect_nav_signals(active_screen)
	transition_started.emit('back', from_screen_id, active_screen.get_id())
	
	var tween := create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property($Camera2D, 'position:x', 1280 * (len(screens_stack)-1), 1)
	await tween.finished
	
	old_screen.exited()
	transition_ended.emit('back', from_screen_id, active_screen.get_id())
	
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
