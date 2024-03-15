extends Treasure

var _beats := 0

func _ready():
	Events.beat.connect(_on_beat)
	
func _on_beat(period:int) -> void:
	_beats = (_beats + 1) % period
	if _beats == 0:
		switch()
		
func switch():
	if collectable:
		collectable = false
		%Sprite2D.visible = false
		%GhostSprite2D.visible = true
		%CollisionShape2D.disabled = true
	else:
		collectable = true
		%Sprite2D.visible = true
		%GhostSprite2D.visible = false
		%CollisionShape2D.disabled = false
