tool
extends Field

export var visible_decorations := true

func _ready():
	var gshape = self.get_gshape()
	
	# connect feedback signal 
	self.connect("entered", self, "_on_Field_entered")
	
	$FeedbackLine.points = gshape.to_closed_PoolVector2Array()
	$Decoration.visible = visible_decorations
	
func _process(delta):
	# keep the symbols up
	$NoCrownSign.rotation = -rotation

func _on_Field_entered(field, body):
	if body is Ball:
		$FeedbackLine.visible = true
		$AnimationPlayer.stop()
		$AnimationPlayer.play("Feedback")
		$AudioStreamPlayer2D.play()
		
