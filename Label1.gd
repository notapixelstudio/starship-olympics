# script Label

extends Label

var count setget _set_score_current

func _ready():
	count = 0

func update_score():
	count += 1
	set_text(str(count))

