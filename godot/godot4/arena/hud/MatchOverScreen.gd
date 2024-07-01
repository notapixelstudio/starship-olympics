extends ColorRect


func _ready() -> void:
	Events.match_over.connect(_on_match_over)
	
func _on_match_over() -> void:
	visible = true
