extends Line2D

func set_full() -> void:
	%AnimationPlayer.play("blink")
	
func set_empty() -> void:
	%AnimationPlayer.play("RESET")
