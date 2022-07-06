extends Sprite

export var content : Resource setget set_content # Might be Minigame.
var status: String = "locked" setget set_status
var selected : bool = false setget set_select
signal unlocked

func set_select(v):
	selected = v
	if not is_inside_tree():
		yield(self, "ready")
	$Select.visible = selected
	
func set_content(v):
	content = v
	if not is_inside_tree():
		yield(self, "ready")
		
	if content is Minigame:
		texture = content.get_icon()
		$Shadow.texture = content.get_icon()
		
		self.update_status()

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
		
func update_status():
	if TheUnlocker.get_status("minigames", content.get_id(), TheUnlocker.HIDDEN) == TheUnlocker.UNLOCKED:
		self.set_status("unlocked")
	else:
		self.set_status("locked")
		
func _enter_tree():
	# this is to support the unlocking of a minicard that's shown in two or more panels
	update_status()
	
