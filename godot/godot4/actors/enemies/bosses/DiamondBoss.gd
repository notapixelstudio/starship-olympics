extends StaticBody2D

@export var textures : Array[Texture]

var _phase := 1

func next_phase() -> void:
	_phase += 1
	%Sprite2D.texture = textures[_phase]
	%Tentacles.position.y -= 60
	%Tentacles.scale = 0.65**(_phase-1)*Vector2(1,1)
	
	# enable just the collision polygon for the current phase
	for node in get_children():
		if node is CollisionPolygon2D:
			if node.name.ends_with(str(_phase)):
				node.disabled = false
			else:
				node.disabled = true
			
