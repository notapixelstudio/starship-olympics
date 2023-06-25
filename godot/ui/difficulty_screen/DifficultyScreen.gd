extends Node2D

var selected_option_name : String

func _ready():
	yield($AnimationPlayer, "animation_finished")
	
	for option in $FancyMenu.get_children():
		option.connect('button_down', self, '_on_option_selected', [option])
		
func _on_option_selected(option):
	selected_option_name = option.name
	Events.emit_signal('difficulty_selection_done')

func get_selected_option_name() -> String:
	return selected_option_name
