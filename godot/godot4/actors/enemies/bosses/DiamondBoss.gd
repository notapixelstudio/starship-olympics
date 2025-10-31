extends Node2D

@export var collision_polygons : Array[CollisionPolygon2D]

var _phase := 0
var _defeated := false

func _ready() -> void:
	Events.sth_collected.connect(_on_sth_collected)

func _on_sth_collected(collector, collectee):
	hit()
	
func hit():
	%HitAnimationPlayer.stop()
	%HitAnimationPlayer.play("hit")

func next_phase() -> void:
	_phase += 1
	Events.log.emit('Boss phase %d' % [_phase])
	
	
	return
	#await _ready_for_next_phase
	
	# create tween and use it to move the boss at the center of the arena
	# wait for the tween to finish
	await get_tree().create_tween().tween_property(self, "position", Vector2(0,0), 2.0).set_ease(Tween.EASE_IN_OUT).finished
	
	
	
	# enable just the collision polygon for the current phase
	for i in len(collision_polygons):
		if _phase-1 == i:
			collision_polygons[i].disabled = false
		else:
			collision_polygons[i].disabled = true
			
			
	# show just the current phase node
	for child in get_children():
		child.visible = child.name.ends_with(str(_phase))
	
	if _phase == 2:
		%RotoTurretPhase2.start()
	elif _phase == 3:
		%RotoTurretPhase2.stop()
		%RotoTurretPhase3.start()
		
	#next_phase_ready.emit()
	
