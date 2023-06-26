extends Control

var navigations := []  # Array of ScreenScene to navigate back
var active_screen: ScreenScene

func navigate_to(screen: PackedScene):
	if active_screen:
		if (active_screen as ScreenScene).is_connected("next", self, "navigate_to"):
			(active_screen as ScreenScene).disconnect("next", self, "navigate_to")
		remove_child(active_screen)
	active_screen = screen.instance()
	assert(active_screen is ScreenScene)
	
	if not active_screen in navigations:
		navigations.append(active_screen)
	add_child(active_screen)
	(active_screen as ScreenScene).connect("next", self, "navigate_to")
	(active_screen as ScreenScene).connect("back", self, "back")
	
	
func back():
	pass

 
