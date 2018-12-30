extends NinePatchRect

onready var tween = get_node("Tween")
onready var scores = $Number

func set_score(point : int):
	scores.text = str(point)	