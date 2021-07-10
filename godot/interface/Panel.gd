extends Control

onready var title = $Title
onready var content = $Content
onready var back_button = $Back

func _ready():
	assert(title)
	assert(content)
	assert(back_button)
