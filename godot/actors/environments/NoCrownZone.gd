tool
extends Field

export var visible_decorations := true
export var symbol_scale := 2.0

func _ready():
	var gshape = self.get_gshape()
	
	# connect feedback signal 
	self.connect("entered", self, "_on_Field_entered")
	
	$FeedbackLine.points = gshape.to_closed_PoolVector2Array()
	$Decoration.visible = visible_decorations
	$NoCrownSign.scale = Vector2(symbol_scale, symbol_scale)
	
func _process(delta):
	# keep the symbols up
	$NoCrownSign.rotation = -rotation

func _on_Field_entered(field, body):
	if body is Ball:
		$FeedbackLine.visible = true
		$AnimationPlayer.stop()
		$AnimationPlayer.play("Feedback")
		$AudioStreamPlayer2D.play()
		
