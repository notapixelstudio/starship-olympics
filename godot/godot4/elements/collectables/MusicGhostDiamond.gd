extends MusicTreasure
class_name MusicGhostDiamond

func _ready():
	super._ready()
	
	if not collectable:
		phase_out()
	
func every_beat() -> void:
	if _beats == 0:
		switch()
	
func switch():
	if collectable:
		collectable = false
		phase_out()
	else:
		collectable = true
		phase_in()

func phase_out():
	%Sprite2D.modulate = Color('#45c2ff2d')
	%CollisionShape2D.disabled = true
	
func phase_in():
	%Sprite2D.modulate = Color.WHITE
	%CollisionShape2D.disabled = false
	shine()
