extends HBoxContainer
@tool

@export var mode: Resource :
	get:
		return mode # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_mode

@onready var title = $Label
@onready var icon = $Icon

func _ready():
	refresh()
	
func refresh():
	if title:
		title.text = mode.name
		icon.texture = mode.icon

func set_mode(_mode: GameMode):
	mode = _mode
	refresh()
	
	
