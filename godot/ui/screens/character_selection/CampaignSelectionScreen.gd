extends BackScreen

export var next_scene : PackedScene

func _on_SelectionPanel_fight(players, fight_mode):
		emit_signal("next", next_scene)
