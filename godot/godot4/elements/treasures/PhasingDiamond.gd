extends Treasure

@export var starting_beats := 0
var _beats := 0

func _ready():
	Events.beat.connect(_on_beat)
	
	_beats = starting_beats
	
	if not collectable:
		phase_out()
	
func _on_beat(period:int) -> void:
	_beats = (_beats + 1) % period
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
	%Sprite2D.visible = false
	%GhostSprite2D.visible = true
	%CollisionShape2D.disabled = true
	
func phase_in():
	%Sprite2D.visible = true
	%GhostSprite2D.visible = false
	%CollisionShape2D.disabled = false
