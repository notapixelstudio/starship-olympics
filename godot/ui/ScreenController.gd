extends Node2D

export var starting_screen_scene : PackedScene

var screens_stack := []  # Array of ScreenScene to navigate back

func _ready():
	navigate_to(starting_screen_scene)

func navigate_to(screen_scene: PackedScene):
	if len(screens_stack) > 0:
		var active_screen = screens_stack[-1]
		if (active_screen as ScreenScene).is_connected("next", self, "navigate_to"):
			(active_screen as ScreenScene).disconnect("next", self, "navigate_to")
		if (active_screen as ScreenScene).is_connected("back", self, "back"):
			(active_screen as ScreenScene).disconnect("back", self, "back")
		active_screen.exit()
	
	var new_screen = screen_scene.instance() as ScreenScene
	assert(new_screen is ScreenScene)
	new_screen.rect_position.x = 1280 * len(screens_stack)
	screens_stack.append(new_screen)
	add_child(new_screen)
	
	var tween := create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property($Camera2D, 'position:x', 1280 * (len(screens_stack)-1), 1)
	yield(tween, "finished")
	
	(new_screen as ScreenScene).connect("next", self, "navigate_to")
	(new_screen as ScreenScene).connect("back", self, "back")
	new_screen.enter()
	
	
func back():
	var old_screen = screens_stack.pop_back()
	old_screen.exit()
	
	var active_screen = screens_stack[-1]
	(active_screen as ScreenScene).connect("next", self, "navigate_to")
	(active_screen as ScreenScene).connect("back", self, "back")
	
	var tween := create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property($Camera2D, 'position:x', 1280 * (len(screens_stack)-1), 1)
	yield(tween, "finished")
	
	old_screen.queue_free()
	active_screen.enter()
