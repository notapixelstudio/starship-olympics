extends CanvasLayer

class_name Alert

export var message: String

func _ready():
	$Alert/Description.bbcode_text = tr("[center]"+message+"[/center]")
	yield(get_tree().create_timer(5), "timeout")
	queue_free()
