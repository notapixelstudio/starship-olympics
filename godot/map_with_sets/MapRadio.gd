@tool
extends CheckBox

class_name RadioOption

@export var value_name : String = "custom_win"
@export var value : Array # workaround for variant types
@export var texture : Texture2D
@export var label = "victories"

var active := false: set = set_active

func _ready():
	
	add_to_group('radio_'+value_name)
	
	$Wrapper/Label.text = label
	
func set_active(v: bool) -> void:
	active = v
	if active:
		$Sprite2D.modulate = Color.WHITE
		$Frame.modulate = Color.WHITE
	else:
		$Sprite2D.modulate = Color(0.5,0.5,0.5,1)
		$Frame.modulate = Color('#24334a')


func _on_RadioOption_focus_entered():
	pass # Replace with function body.
