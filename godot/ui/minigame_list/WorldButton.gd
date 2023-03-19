extends Button

export var indentation_pixels := 0

func _ready():
	$Sprite.position.x -= indentation_pixels

func set_indentation(v) -> void:
	if v:
		$Sprite.position.x += indentation_pixels*2
		
func set_label(v: String) -> void:
	$Label.text = v
	$UnderLabel.text = v
	
func set_image(v: Texture) -> void:
	if v:
		$Sprite.texture = v
		$Shadow.texture = v

# black on yellow
func _on_WorldButton_focus_entered():
	$Label.modulate = Color(0,0,0)
	$UnderLabel.visible = true
	$Sprite.modulate = Color(1,1,1)
	if not disabled:
		$"%FloatAnimationPlayer".play("Float")
	
# white on transparent
func _on_WorldButton_focus_exited():
	$Label.modulate = Color(1,1,1)
	$UnderLabel.visible = false
	$Sprite.modulate = Color(0.6,0.6,0.6)
	$"%FloatAnimationPlayer".play("RESET")
