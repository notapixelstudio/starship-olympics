tool
extends Field

export var symbol_scale := 2.0

var gshape : GShape

func _ready():
	gshape = self.get_gshape()
	
	# connect feedback signal
	self.connect("entered", self, "_on_Field_entered")
	
	gshape.connect("changed", self, "_on_gshape_changed")
	$FeedbackLine.points = gshape.to_closed_PoolVector2Array()
	
	$NoShipSign.scale = Vector2(symbol_scale, symbol_scale)
	
func _process(delta):
	# keep the symbols up
	$NoShipSign.rotation = -rotation
	$Polygon2D.texture_rotation = -rotation

func _on_Field_entered(field, body):
	if body is Ship:
		if body.last_contact_normal != null:
			body.rebound(body.last_contact_normal)
		else:
			body.rebound()
			
		$FeedbackLine.visible = true
		$AnimationPlayer.stop()
		$AnimationPlayer.play("Feedback")
		AudioManager.play($AudioStreamPlayer2D)
		# $AudioStreamPlayer2D.play()
		
func _on_gshape_changed():
	$FeedbackLine.points = gshape.to_closed_PoolVector2Array()
	
