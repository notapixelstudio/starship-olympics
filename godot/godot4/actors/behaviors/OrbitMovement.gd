class_name OrbitMovement extends ActorBehavior

@export var orbit_radius := 150.0
@export var orbit_speed := 1.0
var angle := 0.0
var _definition: PackedScene
var _copy_index := -1
var _copy_count := -1

func configure(host: Node2D, source: Node2D = null) -> void:
	var familiar_root := host as Familiar
	var arrangement_changed := actor != host or self.source != source \
		or (familiar_root != null and (_definition != familiar_root.definition \
		or _copy_index != familiar_root.copy_index or _copy_count != familiar_root.copy_count))
	super.configure(host, source)
	if arrangement_changed:
		angle = TAU * familiar_root.copy_index / familiar_root.copy_count if familiar_root != null else 0.0
	if familiar_root != null:
		_definition = familiar_root.definition
		_copy_index = familiar_root.copy_index
		_copy_count = familiar_root.copy_count

func _ready() -> void:
	super._ready()
	_update_position()

func _physics_process(delta: float) -> void:
	angle = fposmod(angle + orbit_speed * delta, TAU)
	_update_position()

func _update_position() -> void:
	# Counter the owner's rotation so steering does not change the orbit speed.
	var offset := Vector2.from_angle(angle - source.global_rotation) * orbit_radius
	if actor.get_parent() == source:
		actor.position = offset
	else:
		actor.global_position = source.global_position + offset.rotated(source.global_rotation)
	actor.global_rotation = source.global_rotation
