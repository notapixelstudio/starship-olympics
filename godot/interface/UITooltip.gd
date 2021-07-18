tool
extends Node2D

export var tooltip_text: String setget set_tooltip
onready var tooltip = $Tooltip

func set_tooltip(text: String):
	tooltip_text = text
	if not is_inside_tree():
		yield(self, "ready")
	tooltip.text = tooltip_text

