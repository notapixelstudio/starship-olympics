extends StaticBody2D

@export var textures : Array[Texture]

var _phase := 1

signal _ready_for_next_phase
signal next_phase_ready

func next_phase() -> void:
	await _ready_for_next_phase
	
	# create tween and use it to move the boss at the center of the arena
	# wait for the tween to finish
	await get_tree().create_tween().tween_property(self, "position", Vector2(0,0), 0.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE).finished
	
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
				
	%AnimationPlayer.play("Phase"+str(_phase))
	
func _notify_ready_for_next_phase() -> void:
	_ready_for_next_phase.emit()
