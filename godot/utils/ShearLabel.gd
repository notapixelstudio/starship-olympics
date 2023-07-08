@tool
extends Node2D

@export var text : String = '': set = set_text
@export var shear : Vector2 = Vector2(0,0): set = set_shear
@export_enum('left', 'center', 'right') var align = 'center': set = set_align
@export var alien_font : FontFile

func _ready():
	Events.connect("language_changed", Callable(self, '_on_language_changed'))
	
	update_language_font()
	
func set_text(v: String) -> void:
	text = v
	$'%Label'.text = text

func set_shear(v: Vector2) -> void:
	shear = v
	$Wrapper.transform.y.x = shear.x
	$Wrapper.transform.x.y = shear.y
	
func set_align(v: String) -> void:
	align = v
	match align:
		'left':
			$'%Label'.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
			$'%Label'.position.x = 0
		'center':
			$'%Label'.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			$'%Label'.position.x = -300
		'right':
			$'%Label'.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
			$'%Label'.position.x = -600
			
func _on_language_changed():
	update_language_font()
	
func update_language_font():
	if global.language == 'alien':
		$'%Label'.set("theme_override_fonts/font", alien_font)
	else:
		$'%Label'.set("theme_override_fonts/font", null)
