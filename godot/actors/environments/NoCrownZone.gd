extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	var gshape = $Field.get_gshape()
	
	$FeedbackLine.points = gshape.to_closed_PoolVector2Array()
	
	# keep the symbols up
	$NoCrownSign.rotation = -rotation

func _on_Field_entered(field, body):
	if body is Crown:
		$FeedbackLine.visible = true
		$AnimationPlayer.stop()
		$AnimationPlayer.play("Feedback")
		$AudioStreamPlayer2D.play()
		