# script Label

extends Label

var count

func _ready():
	count = 0

func update_score():
	count += 1
	set_text(str(count))

