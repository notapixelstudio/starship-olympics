extends Node2D

export var starting_screen_scene : PackedScene

var screens_stack := []  # Array of ScreenScene to navigate back

func _ready():
	navigate_to(starting_screen_scene)

func navigate_to(screen_scene: PackedScene):
	if len(screens_stack) > 0:
		var active_screen = screens_stack[-1]
		disconnect_nav_signals(active_screen)
		active_screen.exit()
	
	var new_screen = screen_scene.instance() as Screen
	assert(new_screen is Screen)
	new_screen.rect_position.x = 1280 * len(screens_stack)
	screens_stack.append(new_screen)
	add_child(new_screen)
	
	var tween := create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property($Camera2D, 'position:x', 1280 * (len(screens_stack)-1), 1)
	yield(tween, "finished")
	
	connect_nav_signals(new_screen)
	new_screen.enter()
	
	
func back():
	var old_screen = screens_stack.pop_back()
	disconnect_nav_signals(old_screen)
	old_screen.exit()
	
	var active_screen = screens_stack[-1]
	connect_nav_signals(active_screen)
	
	var tween := create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property($Camera2D, 'position:x', 1280 * (len(screens_stack)-1), 1)
	yield(tween, "finished")
	
	old_screen.queue_free()
	active_screen.enter()

func connect_nav_signals(screen : Screen) -> void:
	(screen as Screen).connect("next", self, "navigate_to")
	(screen as Screen).connect("back", self, "back")
	
func disconnect_nav_signals(screen : Screen) -> void:
	if (screen as Screen).is_connected("next", self, "navigate_to"):
		(screen as Screen).disconnect("next", self, "navigate_to")
	if (screen as Screen).is_connected("back", self, "back"):
		(screen as Screen).disconnect("back", self, "back")
