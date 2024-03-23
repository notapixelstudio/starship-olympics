extends Treasure

@export var textures : Array[Texture]

signal grown

func _ready():
	set_texture(textures.pick_random())
	Events.new_objective.connect(_on_new_objective)

func turn_small():
	%Sprite2D.scale = Vector2(0.1,0.1)
	
func grow():
	%GrowAnimation.play('Grow')

func _on_grow_animation_animation_finished(anim_name):
	if anim_name == 'Grow':
		grown.emit()

func enlarge_collision_shape() -> void:
	%CollisionShape2D.shape.radius = 110
	
func restore_collision_shape() -> void:
	%CollisionShape2D.shape.radius = 60

func _on_new_objective(objective) -> void:
	if get_texture() == objective:
		enlarge_collision_shape()
	else:
		restore_collision_shape()
		
