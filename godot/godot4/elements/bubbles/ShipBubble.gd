extends Bubble
class_name ShipBubble

@export var ship_scene : PackedScene : set = set_ship_scene
@export var player : Player : set = set_player
@export var player_brain_scene : PackedScene
@export var cpu_brain_scene : PackedScene

func set_ship_scene(v:PackedScene) -> void:
	ship_scene = v
	_content = ship_scene.instantiate()

func set_player(v:Player) -> void:
	player = v

func _ready() -> void:
	_content.set_player(player)
	var brain
	if player.is_cpu():
		brain = cpu_brain_scene.instantiate() # FIXME clearly wrong, we can't know which brain has to be instantiated
	else:
		brain = player_brain_scene.instantiate()
		brain.set_controls(player.get_controls())
	_content.add_child(brain)
	%ContentSprite2D.texture = player.get_ship_image()

func set_content_rotation(v:float) -> void:
	super(v)
	_content.global_rotation = v
	
func release_content(author) -> void:
	super.release_content(author)
	Events.ship_released.emit.call_deferred(_content, self)
	
func _on_timer_timeout():
	pop()

func disable_auto_popping():
	%Timer.stop()
