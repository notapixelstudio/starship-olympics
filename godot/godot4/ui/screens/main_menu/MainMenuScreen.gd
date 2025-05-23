extends Screen

@export var versus_character_selection_scene : PackedScene
@export var campaign_character_selection_scene : PackedScene
@export var hall_of_fame_scene : PackedScene
@export var settings_scene : PackedScene
@export var credits_scene : PackedScene

func _on_Versus_button_down():
	emit_signal("next", versus_character_selection_scene.instantiate())

func _on_Campaign_button_down():
	emit_signal("next", campaign_character_selection_scene.instantiate())

func _on_HallOfFame_button_down():
	emit_signal("next", hall_of_fame_scene.instantiate())

func _on_Settings_button_down():
	emit_signal("next", settings_scene.instantiate())

func _on_Credits_button_down():
	emit_signal("next", credits_scene.instantiate())

func _on_Quit_button_down():
	$FancyMenu.isolate_child($FancyMenu/Quit)
	global.end_execution()

func exiting():
	$FancyMenu.save_focused_element()
	super.exiting()
	
func enter():
	super.enter()
	$FancyMenu.restore_focused_element()
