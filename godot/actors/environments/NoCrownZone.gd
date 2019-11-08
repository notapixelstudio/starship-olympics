extends Node2D

func _ready():
	var gshape = $Field.get_gshape()
	
	$FeedbackLine.points = gshape.to_closed_PoolVector2Array()
	
func _process(delta):
	# keep the symbols up
	$NoCrownSign.rotation = -rotation

func _on_Field_entered(field, body):
	if body is Crown:
		$FeedbackLine.visible = true
		$AnimationPlayer.stop()
		$AnimationPlayer.play("Feedback")
		$AudioStreamPlayer2D.play()
		