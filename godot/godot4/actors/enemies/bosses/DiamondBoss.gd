extends StaticBody2D

@export var textures : Array[Texture]

var _phase := 1

func next_phase() -> void:
	_phase += 1
	%Sprite2D.texture = textures[_phase]
	%Tentacles.position.y -= 60
	%Tentacles.scale = 0.65**(_phase-1)*Vector2(1,1)
