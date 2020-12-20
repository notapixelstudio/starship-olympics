extends Sprite

export var content : Resource setget set_content
var status: String = "locked" 

signal unlocked

func set_content(v):
	content = v
	if not is_inside_tree():
		yield(self, "ready")
		
	if content is GameMode:
		texture = content.icon
		$Shadow.texture = content.icon

func unlock():
	self.status = "unlocked"
	yield(get_tree().create_timer(1), "timeout")
	emit_signal("unlocked")
	
func _process(delta):
	$Label.text = status
