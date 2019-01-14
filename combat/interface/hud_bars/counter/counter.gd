extends NinePatchRect
var max_count = 13
var count = 0

func _ready():
	count = 0

func _on_Interface_rupees_updated(count):
	$Number.text = str(count) + "/" + str(max_count)
