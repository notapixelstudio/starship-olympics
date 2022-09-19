extends Area2D

export var width := 15
export var height := 9
export var LetterScene : PackedScene
export var letter_side := 200

func _ready():
	for i in range(height):
		for j in range(width):
			var letter = LetterScene.instance()
			letter.global_position = letter_side * Vector2(j-width/2.0, i-height/2.0)
			add_child(letter)
