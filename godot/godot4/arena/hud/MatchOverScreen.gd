extends ColorRect


func _ready() -> void:
	Events.match_over.connect(_on_match_over)
	Events.match_over_anim_ended.connect(_on_match_over_anim_ended)
	
	
func _on_match_over(data:Dictionary) -> void:
	pass#%Winner.text = 'WINNERS: ' + ' '.join(data['winners'])
	
func _on_match_over_anim_ended() -> void:
	%AnimationPlayer.play("appear")
