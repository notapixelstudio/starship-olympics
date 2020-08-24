extends VBoxContainer

signal navigate

func _ready():
	for option in get_children():
		option.connect("nav_to", self, "show_options")


func show_options(options, title):
	emit_signal("navigate", options, title)
