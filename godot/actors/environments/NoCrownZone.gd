extends Node2D


onready var field = $Field
func _ready():
	var gshape = field.get_gshape()
	
	# connect feedback signal 
	field.connect("entered", self, "_on_Field_entered")
	
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
		
