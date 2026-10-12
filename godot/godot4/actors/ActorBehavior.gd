class_name ActorBehavior extends Node2D
## A scene-composed behavior bound to any actor and optional owner.

var actor: Node2D
var source: Node2D

static func bind_children(host: Node2D, source: Node2D = null) -> void:
	for child in host.get_children():
		if child is ActorBehavior:
			child.configure(host, source if source != null else host)

func configure(host: Node2D, source: Node2D = null) -> void:
	actor = host
	self.source = source if source != null else host

func _ready() -> void:
	if actor == null:
		actor = get_parent() as Node2D
	if source == null:
		source = actor
