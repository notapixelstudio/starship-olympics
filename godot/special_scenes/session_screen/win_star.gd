extends TextureRect

onready var won : bool = false setget blink
export var win_texture: StreamTexture
export var lose_texture: StreamTexture

onready var possibilities: Array = [lose_texture, win_texture]

func score():
	$AnimationPlayer.play("won")

func blink(new_value: bool):
	won = new_value
	texture = possibilities[int(won)]
	
	