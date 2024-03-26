@tool
extends HBoxContainer

@export var mode: Resource: set = set_mode

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
	
	
