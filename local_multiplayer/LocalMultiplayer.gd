extends Node

onready var selection_screen = $SelectionScreen

func _ready():
	selection_screen.initialize(global.get_unlocked())