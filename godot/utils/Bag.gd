extends Node2D

export var image : Texture setget set_image
export var amount := 0 setget set_amount
export var item_type : String setget set_item_type

func set_image(v: Texture) -> void:
	image = v
	$Sprite.texture = image
	
func set_amount(v: int) -> void:
	amount = v
	$Value.text = str(amount)
	visible = amount != 0
	
func set_item_type(v: String) -> void:
	item_type = v

func increase() -> void:
	set_amount(amount+1)
	$AnimationPlayer.stop()
	$AnimationPlayer.play("blink")
	
func decrease() -> void:
	set_amount(max(0, amount-1))

func is_empty() -> bool:
	return amount == 0

func has_item_type(type: String) -> bool:
	return item_type == type
