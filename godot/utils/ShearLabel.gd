tool
extends Node2D

export var text : String = '' setget set_text
export var shear : Vector2 = Vector2(0,0) setget set_shear

func set_text(v: String) -> void:
	text = v
	$'%Label'.text = text

func set_shear(v: Vector2) -> void:
	shear = v
	$Wrapper.transform.y.x = shear.x
	$Wrapper.transform.x.y = shear.y
	
