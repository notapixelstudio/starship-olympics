extends ScreenScene

export var versus_character_selection_scene : PackedScene
export var coop_character_selection_scene : PackedScene
export var hall_of_fame_scene : PackedScene
export var settings_scene : PackedScene
export var credits_scene : PackedScene


func _on_Versus_button_down():
	emit_signal("next", versus_character_selection_scene)

func _on_CoOp_button_down():
	emit_signal("next", coop_character_selection_scene)

func _on_HallOfFame_button_down():
	emit_signal("next", hall_of_fame_scene)

func _on_Settings_button_down():
	emit_signal("next", settings_scene)

func _on_Credits_button_down():
	emit_signal("next", credits_scene)

func _on_Quit_button_down():
	global.end_execution()
