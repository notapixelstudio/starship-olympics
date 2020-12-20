extends Sprite

export var content : Resource setget set_content
var status: String = "locked" setget set_status

signal unlocked

func set_content(v):
	content = v
	if not is_inside_tree():
		yield(self, "ready")
		
	if content is GameMode:
		texture = content.icon
		$Shadow.texture = content.icon

func unlock():
	$AnimationPlayer.play("unlock")
	yield($AnimationPlayer, "animation_finished")
	emit_signal("unlocked")
	
func set_status(v):
	status = v
	if status == 'locked':
		self_modulate = Color(0,0,0,0.75)
		$QuestionMark.visible = true
	else:
		self_modulate = Color(1,1,1,1)
		$QuestionMark.visible = false
		
