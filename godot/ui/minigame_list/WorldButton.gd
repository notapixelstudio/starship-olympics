extends Button

export var indentation_pixels := 25

func _ready():
	$Sprite.position.x -= indentation_pixels

func set_indentation(v) -> void:
	if v:
		$Sprite.position.x += indentation_pixels*2
		
func set_text(v: String) -> void:
	$Label.text = v
	$UnderLabel.text = v

# black on yellow
func _on_WorldButton_focus_entered():
	$Label.modulate = Color(0,0,0)
	$UnderLabel.modulate = Color(1,1,1)
	$Sprite.modulate = Color(1,1,1)
# white on transparent
func _on_WorldButton_focus_exited():
	$Label.modulate = Color(1,1,1)
	$UnderLabel.modulate = Color(0,0,0)
	$Sprite.modulate = Color(0.6,0.6,0.6)
	
