extends HBoxContainer

onready var logo = $Sprite
onready var label = $Label

func apply_rule(rule: Rule):
	set_logo(rule.logo)
	set_label(rule.text)

func set_logo(texture: StreamTexture):
	logo.texture = texture

func set_label(description: String):
	label.text = tr(description)
