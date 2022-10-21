tool
extends Ball

export var PfftScene : PackedScene

var active := false

func _ready():
	Events.connect('holdable_loaded', self, '_on_holdable_loaded')
	
func _on_holdable_loaded(holdable, ship):
	if holdable == self:
		active = true
		
func _on_Skull_body_entered(body):
	if body is Bomb:
		dissolve()
		queue_free()
		
func dissolve() -> void:
	var pfft = PfftScene.instance()
	pfft.set_color(Color.gray)
	pfft.scale = Vector2(3,3)
	get_parent().add_child(pfft)
	pfft.global_position = global_position
