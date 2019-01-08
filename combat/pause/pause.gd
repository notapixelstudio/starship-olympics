extends Control

signal standoff
signal standoff_ready
signal reset_signal(level)

onready var menu_buttons = $Buttons

var next_level

func _ready():
	next_level = global.level
	# connect("reset_signal", get_node('/root/Arena'), "reset")


func update_score():
	"""
	update score when the battle ends
	"""
	pass

func standoff():
	emit_signal("standoff_ready")
