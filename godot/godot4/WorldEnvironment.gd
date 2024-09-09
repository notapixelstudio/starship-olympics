extends WorldEnvironment

func _ready():
	Events.connect("glow_setting_changed", Callable(self, 'refresh'))
	
func _enter_tree():
	refresh()
	
func refresh():
	environment.glow_enabled = global.glow_enable
